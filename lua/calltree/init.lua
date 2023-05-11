local M = {}
local lsp = require("calltree.lsp")
local trees = require("calltree.tree")
local call_direction = "from"

function M.DisplayNodes(direction)
    call_direction = direction
    local nodeList = lsp.GetLspNodeList(direction)
    local treeNode = trees.BuildTree(nodeList)
    M.TreeRender(treeNode)
end


function M.TreeRender(nodeList)

    local NuiTree = require("nui.tree")
    local Split = require("nui.split")
    local NuiLine = require("nui.line")

    local split = Split({
      relative = "win",
      position = "bottom",
      size = 25,
    })

    split:mount()

    -- quit
    split:map("n", "q", function()
      split:unmount()
    end, { noremap = true })

    local tree = NuiTree({
      winid = split.winid,
      nodes = nodeList,
      prepare_node = function(node)
        local line = NuiLine()

        line:append(string.rep(" ", 4))
        if node:get_depth() > 1 then
            line:append(string.rep(" ", (node:get_depth() - 1)*2))
            if call_direction == "from" then
                line:append("󱞽 ", "SpecialChar")
            else
                line:append("󱞩 ", "SpecialChar")
            end
        end
        line:append(node.text)
        if node:has_children() then
          line:append(node:is_expanded() and " " or " ", "SpecialChar")
        else
          line:append("")
        end

        return line
      end,
    })

    local map_options = { noremap = true, nowait = true }

    -- print current node
    split:map("n", "<CR>", function()
      local node = tree:get_node()
      split:unmount()
      if node == nil then
          return
      end
      vim.api.nvim_command("e ".. node["node"]["uri"])
      local oriNodeRange = node["node"]["range"]
      vim.api.nvim_command(tostring(oriNodeRange["start"]["line"] + 1))
      vim.api.nvim_win_set_cursor(0,{oriNodeRange["start"]["line"]+1, oriNodeRange["start"]["character"]})
    end, map_options)

    -- collapse current node
    split:map("n", "h", function()
      local node = tree:get_node()
      if node:collapse() then
        tree:render()
      end
    end, map_options)

    -- expand current node
    split:map("n", "l", function()
      local node = tree:get_node()

      if node:expand() then
        tree:render()
      end
    end, map_options)

    tree:render()

    local function expandAll()
      local updated = false

      for _, node in pairs(tree.nodes.by_id) do
        updated = node:expand() or updated
      end

      if updated then
        tree:render()
      end
    end
    expandAll()
end

function M.setup(user_config)
    _ = user_config

    require('calltree.commands').setup()
end



return M
