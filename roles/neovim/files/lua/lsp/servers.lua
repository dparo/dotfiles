local M = {}

local path = require "core.os.path"
local nvim_data_path = path.get_nvim_data_path()
local nvim_cache_path = path.get_nvim_cache_path()

local lspconfig = require "lspconfig"

local home = os.getenv "HOME"
local project_path = vim.fn.getcwd()
local project_basename = vim.fn.fnamemodify(project_path, ":p:h:t")

local jdtls_root_path = path.concat { nvim_data_path, "mason", "packages", "jdtls" }

local function deno_root_dir(fname)
    -- If the top level directory __DOES__ contain a file named `deno.proj` determine that this is a Deno project.
    if (vim.env.DENO_VERSION ~= nil) or (lspconfig.util.root_pattern "deno.proj"(fname) ~= nil) then
        return lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git")(fname)
    end
    return nil
end

local function nodejs_root_dir(fname)
    -- If the top level directory __DOES NOT__ contain a file named `deno.proj` determine that this is a Nodejs project
    if deno_root_dir(fname) == nil then
        return (lspconfig.util.root_pattern "tsconfig.json"(fname) or lspconfig.util.root_pattern("package.json", "jsconfig.json", ".git")(fname))
    end
    return nil
end

M.list = {
    ----- Python: Pyright seems the best performant and modern solution
    -- { name = 'pylsp', config = {} },
    -- { name = 'jedi_language_server', config = {} },
    { name = "pyright", config = {} },

    {
        name = "clangd",
        config = {
            cmd = {
                "clangd",
                "--background-index",
                -- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
                -- to add more checks, create .clang-tidy file in the root directory
                -- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
                "--clang-tidy",
                "--completion-style=bundled",

                -- Used to fix: https://github.com/neovim/neovim/blob/b65a23a13a29176aa669afc5d1c906d1d51e0a39/runtime/lua/vim/lsp/util.lua#L1767-L1784
                --              If I don't set this I get weird messages about neovim not being able to handle different client encodings,
                --              this is possibly because, by default null-ls and other LSP servers default to utf-16 encoding, but clangd
                --              cannot autodetect that it should use utf-16 encoding
                "--offset-encoding=utf-16",

                -- "--cross-file-rename",
                "--header-insertion=iwyu",
            },
        },
    },
    {
        name = "rust_analyzer",
        config = {
            settings = {
                ["rust-analyzer"] = {
                    -- enable clippy on save
                    checkOnSave = {
                        command = "clippy",
                    },
                    imports = {
                        granularity = {
                            group = "module",
                        },
                        prefix = "self",
                    },
                    cargo = {
                        buildScripts = {
                            enable = true,
                        },
                    },
                    procMacro = {
                        enable = true,
                    },
                },
            },
        },
    },
    { name = "cmake", config = {} },
    {
        name = "bashls",
        config = {
            cmd = { "bash-language-server", "start" },
            cmd_env = { GLOB_PATTERN = "*@(.sh|.inc|.bash|.command)" },
            filetypes = { "sh", "bash" },
        },
    },
    {
        name = "texlab",
        config = {
            settings = {
                texlab = {
                    latexFormatter = "latexindent",
                    latexindent = {
                        modifyLineBreaks = true,
                    },
                },
            },
        },
    },
    { name = "ltex", config = {} }, --- LateX language server: LSP language server for LanguageTool (requires ltex-ls binary in path)
    { name = "lemminx", config = {
        settings = {
            xml = {
                server = {
                    workDir = path.concat { home, '.cache', 'lemminx' }
                }
            }
        }
    }
    },
    {
        name = "jsonls",
        config = {
            settings = {
                json = {
                    schemas = require("schemastore").json.schemas(),
                    validate = { enable = true },
                },
            },
        },
    },
    { name = "yamlls", config = { settings = { yaml = { keyOrdering = false } } } },
    -- { name = "vuels", config = {} },      -- npm install -g vls or MasonInstall vetur-vls [[OLD]], only for Vue 2
    { name = "volar",  config = {} }, -- npm install -g @vue/language-server or MasonInstall vue-language-server, supports Vue 2 and Vue 3r
    { name = "svelte", config = {} }, -- npm install -g svelte-language-server or MasonInstall svelte-language-server
    {
        name = "tsserver",
        config = {
            root_dir = nodejs_root_dir,
            settings = {
                typescript = {
                    inlayHints = {
                        includeInlayParameterNameHints = "all",
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    },
                },
                javascript = {
                    inlayHints = {
                        includeInlayParameterNameHints = "all",
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    },
                },
            },
        },
    },
    { name = "eslint", config = {} },
    -- { name = "rome", config = {} },
    -- { name = "relay_lsp", config = {} }, -- https://github.com/facebook/relay
    { name = "angularls", config = {} },
    { name = "ansiblels", config = {} },
    { name = "terraformls", config = {} },
    {
        name = "jdtls",
        config = function()
            local config = {
                cmd = {
                    -- NOTE(d.paro): At the time of writing, Wed 23 2022, eclipse.jdt.ls requires Java 17 or higher
                    --         See https://github.com/mfussenegger/nvim-jdtls#configuration-quickstart
                    --         If this ever changes in the future
                    "/usr/lib/jvm/java-17-openjdk/bin/java",
                    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                    "-Dosgi.bundles.defaultStartLevel=4",
                    "-Declipse.product=org.eclipse.jdt.ls.core.product",
                    "-Djava.maven.downloadSources=true",
                    "-Dlog.protocol=true",
                    "-Dlog.level=ALL",
                    -- https://projectlombok.org/
                    "-javaagent:" .. path.concat { nvim_data_path, "mason", "packages", "jdtls", "lombok.jar" },
                    "-Xms1g",
                    "--add-modules=ALL-SYSTEM",
                    "--add-opens",
                    "java.base/java.util=ALL-UNNAMED",
                    "--add-opens",
                    "java.base/java.lang=ALL-UNNAMED",
                    "-jar",
                    vim.fn.glob(path.concat { jdtls_root_path, "plugins", "org.eclipse.equinox.launcher_*.jar" }),
                    "-configuration",
                    path.concat { jdtls_root_path, "config_linux" },
                    "-data",
                    path.concat { nvim_cache_path, "jdtls", string.gsub(project_path, path.separator, "%%") },
                },
                root_dir = require("jdtls.setup").find_root {
                    ".git",
                    "mvnw",
                    "gradlew",
                    "build.xml",
                    "pom.xml",
                    "settings.gradle",
                    "settings.gradle.kts",
                    "build.gradle",
                    "build.gradle.kts",
                },
                -- Here you can configure eclipse.jdt.ls specific settings
                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                -- for a list of options
                settings = {
                    jdt_uri_timeout_ms = 20000,
                    java = {
                        maven = {
                            downloadSources = true,
                        },
                        signatureHelp = { enabled = true },
                        sources = {
                            organizeImports = {
                                starThreshold = 9999,
                                staticStarThreshold = 9999,
                            },
                        },
                        codeGeneration = {
                            toString = {
                                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                            },
                            hashCodeEquals = {
                                useJava7Objects = true,
                            },
                            useBlocks = true,
                        },
                        configuration = {
                            -- Configure the JAVA runtimes available to eclipse.
                            --    Can switch Java Runtime from neovim after starting with :JdtSetRuntime
                            runtimes = {
                                {
                                    name = "JavaSE-1.8",
                                    path = "/usr/lib/jvm/java-1.8.0-openjdk/",
                                },
                                {
                                    name = "JavaSE-11",
                                    path = "/usr/lib/jvm/java-11-openjdk/",
                                },
                                {
                                    name = "JavaSE-17",
                                    path = "/usr/lib/jvm/java-17-openjdk/",
                                },
                            },
                        },
                        format = {
                            enabled = true,
                            tabSize = 4,
                            insertSpaces = true,
                            onType = false,
                            settings = {
                                profile = "GoogleStyle",
                                url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
                            },
                        },
                    },
                },
                init_options = {
                    extendedClientCapabilities = {
                        progressReportProvider = true,
                        classFileContentsSupport = true,
                        generateToStringPromptSupport = true,
                        hashCodeEqualsPromptSupport = true,
                        advancedExtractRefactoringSupport = true,
                        advancedOrganizeImportsSupport = true,
                        generateConstructorsPromptSupport = true,
                        generateDelegateMethodsPromptSupport = true,
                        moveRefactoringSupport = true,
                        overrideMethodsPromptSupport = true,
                        inferSelectionSupport = { "extractMethod", "extractVariable", "extractConstant" },
                        resolveAdditionalTextEditsSupport = true,
                    },
                },
            }

            local bundles = {}

            -- See : https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
            vim.list_extend(
                bundles,
                vim.split(
                    vim.fn.glob(
                        path.concat {
                            nvim_data_path,
                            "mason",
                            "packages",
                            "java-debug-adapter",
                            "extension",
                            "server",
                            "com.microsoft.java.debug.plugin-*.jar",
                        },
                        1
                    ),
                    "\n"
                )
            )

            -- See: https://github.com/mfussenegger/nvim-jdtls#vscode-java-test-installation
            vim.list_extend(
                bundles,
                vim.split(
                    vim.fn.glob(
                        path.concat {
                            nvim_data_path,
                            "mason",
                            "packages",
                            "java-test",
                            "extension",
                            "server",
                            "*.jar",
                        },
                        1
                    ),
                    "\n"
                )
            )

            config["init_options"] = config["init_options"] or {}
            config["init_options"].bundles = bundles

            -- mute; having progress reports is enough
            if false then
                config.handlers = config.handlers or {}
                config.handlers["language/status"] = function() end
            end

            return config
        end,
    },
    {
        name = "metals",
        config = {
            showImplicitArguments = true,
            excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
        },
    },
    {
        name = "denols",
        config = {
            -- cmd = { "deno", "lsp"},
            init_options = {
                enable = true,
                lint = true,
                unstable = false,
            },
            root_dir = deno_root_dir,
        },
    },
    { name = "gopls",                    config = {} },
    { name = "vimls",                    config = {} },
    { name = "html",                     config = {} },
    { name = "zls",                      config = {} },
    { name = "nim_langserver",           config = {} },
    { name = "ocamllsp",                 config = {} },
    { name = "cucumber_language_server", config = {} },

    -- NOTE: We use null-ls now, which is more richer in terms of features
    --       and lives inside the neovim process space instead of being a separate
    --       go program
    -- { name = 'efm', config = {
    --     init_options = {documentFormatting = true},
    --     filetypes = { "lua", "sh", "bash", "make"}
    -- }},
    { name = "marksman", config = {} },
    { name = "julials", config = {} },
    {
        name = "lua_ls",
        config = function()
            local runtime_path = vim.split(package.path, ";")
            table.insert(runtime_path, "lua/?.lua")
            table.insert(runtime_path, "lua/?/init.lua")

            return {
                settings = {
                    Lua = {
                        hint = {
                            enable = true,
                        },
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                            version = "LuaJIT",
                            -- Setup your lua path
                            path = runtime_path,
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { "vim" },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }
        end,
    },
}



if (vim.env.NVIM_LSP_DISABLED ~= nil and vim.env.NVIM_LSP_DISABLED ~= "0") then
    M.list = {}
end

function M.get_config(name)
    if (vim.env.NVIM_LSP_DISABLED ~= nil and vim.env.NVIM_LSP_DISABLED ~= "0") then
        return nil
    end
    for _, server in ipairs(M.list) do
        if server.name == name then
            return server.config
        end
    end
    return nil
end

return M
