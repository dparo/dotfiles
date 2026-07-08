package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/AzureAD/microsoft-authentication-library-for-go/apps/public"
)

const (
	lookAhead = 15 * time.Minute
	grace     = 5 * time.Minute
)

var scopes = []string{
	"https://graph.microsoft.com/Calendars.Read",
}

type GraphResponse struct {
	Value []Event `json:"value"`
}

type Event struct {
	ID      string `json:"id"`
	Subject string `json:"subject"`

	Start struct {
		DateTime string `json:"dateTime"`
		TimeZone string `json:"timeZone"`
	} `json:"start"`

	Location struct {
		DisplayName string `json:"displayName"`
	} `json:"location"`

	IsAllDay bool `json:"isAllDay"`
}

type NotificationCache map[string]int64

func main() {
	clientID := os.Getenv("CLIENT_ID")
	if clientID == "" {
		fatal("CLIENT_ID not set")
	}

	tenantID := os.Getenv("TENANT_ID")
	if tenantID == "" {
		tenantID = "common"
	}

	token, err := acquireToken(clientID, tenantID)
	if err != nil {
		fatal(err.Error())
	}

	events, err := fetchEvents(token)
	if err != nil {
		fatal(err.Error())
	}

	cache := loadNotificationCache()

	now := time.Now()

	for _, ev := range events {
		if ev.IsAllDay {
			continue
		}

		start, err := parseGraphTime(ev.Start.DateTime)
		if err != nil {
			continue
		}

		diff := start.Sub(now)

		if diff > lookAhead {
			continue
		}

		if diff < -grace {
			continue
		}

		if alreadyNotified(cache, ev.ID, start) {
			continue
		}

		sendNotification(ev, diff)

		cache[ev.ID] = start.Unix()
	}

	saveNotificationCache(cache)
}

func acquireToken(clientID, tenantID string) (string, error) {
	authority := fmt.Sprintf(
		"https://login.microsoftonline.com/%s",
		tenantID,
	)

	app, err := public.New(
		clientID,
		public.WithAuthority(authority),
	)
	if err != nil {
		return "", err
	}

	accounts, err := app.Accounts(context.Background())
	if err == nil && len(accounts) > 0 {
		result, err := app.AcquireTokenSilent(
			context.Background(),
			scopes,
			public.WithSilentAccount(accounts[0]),
		)

		if err == nil {
			return result.AccessToken, nil
		}
	}

	deviceCode, err := app.AcquireTokenByDeviceCode(
		context.Background(),
		scopes,
	)

	if err != nil {
		return "", err
	}

	fmt.Println(deviceCode.Result.Message)

	result, err := deviceCode.AuthenticationResult(context.Background())
	if err != nil {
		return "", err
	}

	return result.AccessToken, nil
}

func fetchEvents(token string) ([]Event, error) {
	now := time.Now()

	start := now.Format(time.RFC3339)
	end := now.Add(24 * time.Hour).Format(time.RFC3339)

	u := fmt.Sprintf(
		"https://graph.microsoft.com/v1.0/me/calendarView?startDateTime=%s&endDateTime=%s&$select=id,subject,start,location,isAllDay",
		url.QueryEscape(start),
		url.QueryEscape(end),
	)

	req, err := http.NewRequest("GET", u, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Prefer", `outlook.timezone="UTC"`)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return nil, errors.New(string(body))
	}

	var result GraphResponse

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	return result.Value, nil
}

func sendNotification(ev Event, diff time.Duration) {
	title := "📅 " + ev.Subject

	var body string

	switch {
	case diff >= 0:
		body = fmt.Sprintf(
			"Starts in %d minutes",
			int(diff.Minutes()),
		)

	default:
		body = fmt.Sprintf(
			"Started %d minutes ago",
			int((-diff).Minutes()),
		)
	}

	if ev.Location.DisplayName != "" {
		body += "\n" + ev.Location.DisplayName
	}

	cmd := exec.Command(
		"notify-send",
		title,
		body,
	)

	_ = cmd.Run()
}

func parseGraphTime(s string) (time.Time, error) {
	layouts := []string{
		time.RFC3339,
		"2006-01-02T15:04:05.9999999",
		"2006-01-02T15:04:05",
	}

	for _, layout := range layouts {
		t, err := time.Parse(layout, s)
		if err == nil {
			return t, nil
		}
	}

	return time.Time{}, errors.New("unable to parse datetime")
}

func cachePath() string {
	home, _ := os.UserHomeDir()

	return filepath.Join(
		home,
		".cache",
		"calendar-reminder.json",
	)
}

func loadNotificationCache() NotificationCache {
	path := cachePath()

	data, err := os.ReadFile(path)
	if err != nil {
		return NotificationCache{}
	}

	var cache NotificationCache

	if json.Unmarshal(data, &cache) != nil {
		return NotificationCache{}
	}

	return cache
}

func saveNotificationCache(cache NotificationCache) {
	path := cachePath()

	_ = os.MkdirAll(filepath.Dir(path), 0755)

	data, _ := json.MarshalIndent(cache, "", "  ")

	_ = os.WriteFile(path, data, 0644)
}

func alreadyNotified(
	cache NotificationCache,
	eventID string,
	start time.Time,
) bool {
	last, ok := cache[eventID]
	if !ok {
		return false
	}

	return last == start.Unix()
}

func fatal(msg string) {
	fmt.Fprintln(os.Stderr, msg)
	os.Exit(1)
}
