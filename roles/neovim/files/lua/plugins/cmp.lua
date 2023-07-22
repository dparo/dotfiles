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
            "jose-elias-alvarez/null-ls.nvim",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "petertriho/cmp-git",
            "kristijanhusak/vim-dadbod-completion",
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
                mapping = {
                    -- Specify `cmp.config.disable` if you want to remove a default mapping.
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    -- ["<C-Space>"] = cmp.mapping.complete(),
                    -- ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),

                    -- ["<Esc>"] = cmp.mapping(function(fallback)
                    --     if cmp.visible() then
                    --         local entry = cmp.get_selected_entry()
                    --         if not entry then
                    --             fallback()
                    --         else
                    --             cmp.abort()
                    --             -- cmp.confirm { behaviour = confirm_behaviour, select = false }
                    --         end
                    --     else
                    --         fallback()
                    --     end
                    -- end, { "i", "s" }),
                    ["<C-y>"] = cmp.config.disable,
                    ["<C-a>"] = cmp.mapping {
                        i = abort_and_fallback(),
                        c = abort_and_fallback(),
                    },
                    ["<C-e>"] = cmp.mapping {
                        i = abort_and_fallback { behaviour = confirm_behaviour, select = false },
                        c = abort_and_fallback { behaviour = confirm_behaviour, select = false },
                    },

                    ["<C-Space>"] = cmp.mapping.complete(),

                    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ["<CR>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            local entry = cmp.get_selected_entry()
                            if not entry then
                                fallback()
                                cmp.abort()
                            else
                                cmp.confirm()
                            end
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    -- cmp.mapping.confirm { behaviour = confirm_behaviour, select = false },

                    -- Setup super tab
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if snippets_enabled and luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif cmp.visible() then
                            cmp.select_next_item(select_opts)
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            -- The fallback function sends an already mapped key.
                            -- In this case, it's probably <Tab>
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if snippets_enabled and luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        elseif cmp.visible() then
                            cmp.select_prev_item(select_opts)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<Up>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            local entry = cmp.get_selected_entry()
                            if not entry then
                                fallback()
                                cmp.abort()
                            else
                                cmp.select_prev_item(select_opts)
                            end
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<Down>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            local entry = cmp.get_selected_entry()
                            if not entry then
                                fallback()
                                cmp.abort()
                            else
                                cmp.select_next_item(select_opts)
                            end
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },

                -- IMPORTANT: The order of the sources is important. It establishes priority between source candidates
                sources = cmp.config.sources({
                    { name = "nvim_lsp", keyword_length = 3 },
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
