local M = {}

function M.setup()
    vim.cmd("command! IncomingTree      lua require('calltree.init').DisplayNodes('from')")
    vim.cmd("command! OutingTree      lua require('calltree.init').DisplayNodes('to')")
end

return M
