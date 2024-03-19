return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "leoluz/nvim-dap-go",
            "theHamsta/nvim-dap-virtual-text",
            "mxsdev/nvim-dap-vscode-js",
            -- "folke/neodev.nvim",
        },
        config = function()
            local dap = require "dap"
            local path = require "core.os.path"
            local nvim_data_path = path.get_nvim_data_path()

            local augroup = vim.api.nvim_create_augroup("USER_DAP", { clear = true })

            local chrome_debug_adapter_path = path.concat { nvim_data_path, "mason", "packages", "chrome-debug-adapter" }
            local firefox_debug_adapter_path = path.concat { nvim_data_path, "mason", "packages", "firefox-debug-adapter" }

            require("dap-vscode-js").setup {
                debugger_path = vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter",
                debugger_cmd = { "js-debug-adapter" },
                adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
            }

            -- DAP ui
            local dapui = require "dapui"
            require("dapui").setup()

            require("nvim-dap-virtual-text").setup {
                enabled = true,
                commented = false,
                only_first_definition = false,
                all_references = true,
                virt_lines = false,
            }

            -- Automatically open/close the UI when starting/finishing debugging
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
                require("nvim-dap-virtual-text/virtual_text").clear_virtual_text()
                vim.fn.execute [[bd dap-preview]]
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
                require("nvim-dap-virtual-text/virtual_text").clear_virtual_text()
                vim.fn.execute [[bd dap-preview]]
            end

            dap.listeners.after.event_exited["nvim-dap-virtual-text"] = function()
                require("nvim-dap-virtual-text/virtual_text").clear_virtual_text()
            end

            --- Extension for GO/delve
            require("dap-go").setup()

            dap.adapters.cppdbg = {
                id = "cppdbg",
                type = "executable",
                command = path.concat {
                    nvim_data_path,
                    "mason",
                    "packages",
                    "cpptools",
                    "extension",
                    "debugAdapters",
                    "bin",
                    "OpenDebugAD7",
                },
            }

            dap.adapters.chrome = {
                type = "executable",
                command = "node",
                args = { path.concat { chrome_debug_adapter_path, "out", "src", "chromeDebug.js" } },
            }

            dap.adapters.firefox = {
                type = "executable",
                command = "node",
                args = { path.concat { firefox_debug_adapter_path, "firefox-debug-adapter" } },
            }

            dap.configurations.cpp = {
                {
                    name = "Launch file",
                    type = "cppdbg",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = true,
                    setupCommands = {
                        {
                            text = "-enable-pretty-printing",
                            description = "enable pretty printing",
                            ignoreFailures = false,
                        },
                    },
                },
                {
                    name = "Attach to gdbserver :1234",
                    type = "cppdbg",
                    request = "launch",
                    MIMode = "gdb",
                    miDebuggerServerAddress = "localhost:1234",
                    miDebuggerPath = "/usr/bin/gdb",
                    cwd = "${workspaceFolder}",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    setupCommands = {
                        {
                            text = "-enable-pretty-printing",
                            description = "enable pretty printing",
                            ignoreFailures = false,
                        },
                    },
                },
                {
                    name = "Attach to process",
                    type = "cpp",
                    request = "attach",
                    pid = require("dap.utils").pick_process,
                    args = {},
                },
            }

            dap.configurations.c = dap.configurations.cpp

            dap.configurations.java = {
                {
                    type = "java",
                    request = "attach",
                    name = "Java - Attach localhost:5005",
                    hostname = "127.0.0.1",
                    port = function()
                        return vim.fn.input("Port: ", 5005)
                    end,
                },
            }

            for _, language in ipairs { "typescript", "javascript", "typescriptreact" } do
                dap.configurations[language] = {}

                vim.list_extend(dap.configurations[language], {
                    {
                        name = "[pwa-node] Launch",
                        type = "pwa-node",
                        request = "launch",
                        program = "${file}",
                        rootPath = "${workspaceFolder}",
                        cwd = "${workspaceFolder}",
                        sourceMaps = true,
                        skipFiles = { "<node_internals>/**" },
                        protocol = "inspector",
                        console = "integratedTerminal",
                    },
                    {
                        name = "[pwa-node] Attach to node process",
                        type = "pwa-node",
                        request = "attach",
                        rootPath = "${workspaceFolder}",
                        processId = require("dap.utils").pick_process,
                    },
                    {
                        name = "[pwa-node] Debug Main Process (Electron)",
                        type = "pwa-node",
                        request = "launch",
                        program = "${workspaceFolder}/node_modules/.bin/electron",
                        args = {
                            "${workspaceFolder}/dist/index.js",
                        },
                        outFiles = {
                            "${workspaceFolder}/dist/*.js",
                        },
                        resolveSourceMapLocations = {
                            "${workspaceFolder}/dist/**/*.js",
                            "${workspaceFolder}/dist/*.js",
                        },
                        rootPath = "${workspaceFolder}",
                        cwd = "${workspaceFolder}",
                        sourceMaps = true,
                        skipFiles = { "<node_internals>/**" },
                        protocol = "inspector",
                        console = "integratedTerminal",
                    },
                    {
                        name = "[pwa-node] Compile & Debug Main Process (Electron)",
                        type = "pwa-node",
                        request = "launch",
                        preLaunchTask = "npm run build-ts",
                        program = "${workspaceFolder}/node_modules/.bin/electron",
                        args = {
                            "${workspaceFolder}/dist/index.js",
                        },
                        outFiles = {
                            "${workspaceFolder}/dist/*.js",
                        },
                        resolveSourceMapLocations = {
                            "${workspaceFolder}/dist/**/*.js",
                            "${workspaceFolder}/dist/*.js",
                        },
                        rootPath = "${workspaceFolder}",
                        cwd = "${workspaceFolder}",
                        sourceMaps = true,
                        skipFiles = { "<node_internals>/**" },
                        protocol = "inspector",
                        console = "integratedTerminal",
                    },
                })

                vim.list_extend(dap.configurations[language], {
                    {
                        name = "[chrome-debug-adapter] Chrome Debug Attach",
                        type = "chrome",
                        request = "attach",
                        sourceMaps = true,
                        trace = true,
                        url = "http://127.0.0.1",
                        hostName = "127.0.0.1",
                        port = function()
                            return vim.fn.input("Port: ", "4200")
                        end,
                        webRoot = "${workspaceFolder}",
                    },
                    {
                        name = "[firefox-debug-adapter] Firefox Debug Launch",
                        type = "firefox",
                        request = "launch",
                        reAttach = true,
                        url = function()
                            return "http://127.0.0.1" .. vim.fn.input("Port: ", "4200")
                        end,
                        webRoot = "${workspaceFolder}",
                    },
                })
            end

            vim.keymap.set("n", "<F5>", dap.continue)
            vim.keymap.set("n", "<S-F5>", function()
                dap.terminate()
            end)

            -- <S-F5>
            vim.keymap.set("n", "<F17>", function()
                dap.terminate()
            end)

            -- <M-F5>
            vim.keymap.set("n", "<F53>", function()
                dap.run_last()
            end)

            vim.keymap.set("n", "<leader>dh", function()
                require("dap.ui.widgets").hover()
            end)
            vim.keymap.set("n", "<leader>dp", function()
                require("dap.ui.widgets").preview()
            end)

            if false then
                vim.api.nvim_create_autocmd({ "CursorHold" }, {
                    group = augroup,
                    callback = function()
                        if dap.status() ~= "" then
                            pcall(require("dap.ui.widgets").preview, nil)
                        end
                    end,
                })
            end

            vim.keymap.set("n", "<F34>", dap.run_to_cursor) -- C-F10
            vim.keymap.set("n", "<leader>dc", dap.continue)
            vim.keymap.set("n", "<F10>", dap.step_over)
            vim.keymap.set("n", "<F11>", dap.step_into)
            vim.keymap.set("n", "<S-F11>", dap.step_out)
            vim.keymap.set("n", "<F23>", dap.step_out)

            vim.keymap.set("n", "<F9>", dap.toggle_breakpoint)
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
            vim.keymap.set("n", "<leader>dd", function()
                require('dapui').toggle()
            end)
            vim.keymap.set("n", "<leader>dB", function()
                dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
            end)

            vim.keymap.set("n", "<leader>dx", function()
                dap.repl.open()
            end)
            vim.keymap.set("n", "<leader>dc", dap.continue)
            vim.keymap.set("n", "<leader>ds", function()
                dap.goto_()
            end)

            vim.keymap.set("n", "<leader>dk", dap.up)
            vim.keymap.set("n", "<leader>d<Up>", dap.up)
            vim.keymap.set("n", "<leader>dj", dap.down)
            vim.keymap.set("n", "<leader>d<Down>", dap.up)

            vim.keymap.set("n", "<leader>deb", function()
                dap.set_exception_breakpoints()
            end) -- Break on exception
            vim.keymap.set("n", "<leader>deB", function()
                dap.set_exception_breakpoints {}
            end) -- Clear exception breaks
        end,
    },
}
