return {

    -- Install LuaSnip and load friendly-snippets (a set of already pre-packaged set of snippets)
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    ----
    ---- Packages that take neovim to a whole new level like a full IDE or VSCode experience
    ----
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "windwp/nvim-autopairs",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "nvim-tree/nvim-web-devicons",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "petertriho/cmp-git",
            "kristijanhusak/vim-dadbod-completion",
            "supermaven-inc/supermaven-nvim"
        },
        config = function()
            local snippets_enabled = false

            require("nvim-autopairs").setup()
            local cmp_autopairs = require "nvim-autopairs.completion.cmp"

            local cmp = require "cmp"
            local luasnip = require "luasnip"

            local has_words_before = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
            end

            local feedkey = function(key, mode)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
            end

            local function abort_and_fallback(...)
                return function(fallback)
                    cmp.abort()
                    fallback()
                end
            end

            local function close_and_fallback(...)
                return function(fallback)
                    cmp.close(arg)
                    fallback()
                end
            end

            local function confirm_and_fallback(...)
                return function(fallback)
                    cmp.confirm(arg)
                    fallback()
                end
            end

            local select_behaviour = cmp.SelectBehavior.Select
            local select_opts = { behaviour = select_behaviour }
            -- local confirm_behaviour = cmp.ConfirmBehavior.Insert
            local confirm_behaviour = cmp.ConfirmBehavior.Replace

            local function border(hl_name)
                return {
                    { "╭", hl_name },
                    { "─", hl_name },
                    { "╮", hl_name },
                    { "│", hl_name },
                    { "╯", hl_name },
                    { "─", hl_name },
                    { "╰", hl_name },
                    { "│", hl_name },
                }
            end

            cmp.setup {
                window = {
                    completion = {
                        border = border "CmpBorder",
                        winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
                    },
                    documentation = {
                        border = border "CmpDocBorder",
                    },
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        local icons = require("lsp.icons").default
                        local kind = vim_item.kind

                        local menu = entry.source.name
                        if menu == "vim-dadbod-completion" then
                            menu = "DB"
                        end

                        vim_item.kind = string.format("%s %s", icons[kind] or "", kind)
                        vim_item.menu = string.format("[%s]", menu)
                        return vim_item
                    end,
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                enabled = function()
                    local buftype = vim.api.nvim_buf_get_option(0, "buftype")
                    if buftype == "prompt" then
                        return false
                    end

                    -- Disable completion in comments
                    local context = require "cmp.config.context"
                    -- keep command mode completion enabled when cursor is in a comment
                    if vim.api.nvim_get_mode().mode == "c" then
                        return true
                    else
                        return not context.in_treesitter_capture "comment" and not context.in_syntax_group "Comment"
                    end
                end,
                mapping = cmp.mapping.preset.insert {
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                },
                -- IMPORTANT: The order of the sources is important. It establishes priority between source candidates
                sources = cmp.config.sources({
                    { name = "nvim_lsp", keyword_length = 3 },
                    { name = "supermaven" },
                    -- { name = "nvim_lsp_signature_help" },
                    { name = "nvim_lua", keyword_length = 3 },
                    { name = "luasnip", keyword_length = 3 },
                    { name = "vim-dadbod-completion", keyword_length = 3 },
                }, {
                    { name = "buffer", keyword_length = 3 },
                    { name = "path", keyword_length = 3 },
                    { name = "luasnip", keyword_length = 3 },
                }),
            }

            -- Set configuration for specific filetype.
            if vim.env.GITHUB_API_TOKEN ~= nil then
                cmp.setup.filetype("gitcommit", {
                    sources = cmp.config.sources({
                        { name = "cmp_git", keyword_length = 3 }, -- You can specify the `cmp_git` source if you were installed it.
                    }, {
                        { name = "buffer", keyword_length = 3 },
                    }),
                })
            end

            -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
            if false then
                cmp.setup.cmdline("/", {
                    view = {
                        entries = { name = "wildmenu", separator = "|" },
                    },
                    sources = {
                        { name = "buffer", keyword_length = 3 },
                    },
                })
            end

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(":", {
                sources = cmp.config.sources({
                    { name = "path", keyword_length = 3 },
                }, {
                    { name = "cmdline", keyword_length = 3 },
                }),
            })

            -- Fix for nvim-autopair
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
        end,
    },
}
