local dap = require "dap"

local path = require "core.os.path"
local nvim_data_path = path.get_nvim_data_path()

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
    dapui.open { nil, true }
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close { nil }
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close { nil }
end

dap.listeners.after.event_exited["nvim-dap-virtual-text"] = function()
    require('nvim-dap-virtual-text/virtual_text').clear_virtual_text()
end


--- Extension for GO/delve
require("dap-go").setup()

dap.adapters.cppdbg = {
    id = "cppdbg",
    type = "executable",
    command = path.concat { nvim_data_path, "mason", "packages", "cpptools", "extension", "debugAdapters", "bin",
        "OpenDebugAD7" },
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
        type = 'cpp',
        request = 'attach',
        pid = require('dap.utils').pick_process,
        args = {},
    }
}

dap.configurations.c = dap.configurations.cpp


dap.configurations.java = {
    {
        type = 'java',
        request = 'attach',
        name = 'Java - Attach localhost:5005',
        hostname = '127.0.0.1',
        port = 5005,
    }
}

local function terminate_callback()
    dapui.close { nil }
    require('nvim-dap-virtual-text/virtual_text').clear_virtual_text()

end

vim.keymap.set("n", "<F5>", dap.continue)
vim.keymap.set("n", "<S-F5>", function() dap.terminate(nil, nil, terminate_callback) end)
vim.keymap.set("n", "<F17>", function() dap.terminate(nil, nil, terminate_callback) end)
vim.keymap.set("n", "<F53>", function() dap.run_last() end) -- M-F5


vim.keymap.set("n", "<leader>dh", function() require('dap.ui.widgets').hover() end)
vim.keymap.set("n", "<leader>dp", function() require('dap.ui.widgets').preview() end)

vim.keymap.set("n", "<F34>", dap.run_to_cursor) -- C-F10
vim.keymap.set("n", "<leader>dc", dap.continue)
vim.keymap.set("n", "<F10>", dap.step_over)
vim.keymap.set("n", "<F11>", dap.step_into)
vim.keymap.set("n", "<S-F11>", dap.step_out)
vim.keymap.set("n", "<F23>", dap.step_out)

vim.keymap.set("n", "<F9>", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
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

vim.keymap.set("n", "<leader>deb", function()
    dap.set_exception_breakpoints()
end) -- Break on exception
vim.keymap.set("n", "<leader>deB", function()
    dap.set_exception_breakpoints {}
end) -- Clear exception breaks
