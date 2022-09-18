local M = {}
local utils = require("calltree.utils")
local beginStartIndex = 100

function M.GetStartIndex()
    return beginStartIndex
end
function M.GetLspNodeList(direction)
    if direction == nil then
        direction = "from"
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local params = utils.make_position_params()
    local timeout_ms = 1000000
    local client = vim.lsp.get_active_clients()[1]
    local result, _ = client.request_sync('textDocument/prepareCallHierarchy', params,timeout_ms,bufnr)
    local curNode = result["result"][1]

    local nodeList = {}
    local stack = {}
    local stackNode = {}

    local node = {}
    local startIndex = beginStartIndex
    node["id"] = startIndex
    node["text"] = curNode["name"]
    node["node"] = curNode
    node["parent_id"] = nil

    table.insert(stack, curNode)
    table.insert(stackNode, node)
    table.insert(nodeList, node)

    local indexNode = table.remove(stack)
    local indexStackNode = table.remove(stackNode)
    local mapNode = {}
    mapNode[curNode["name"]] = true
    local method = 'callHierarchy/incomingCalls'
    if direction == "to" then
        method = 'callHierarchy/outgoingCalls'
    end

    while indexNode ~= nil do
        result, _ = client.request_sync(method,{item=indexNode, timeout_ms, bufnr})
        if result["result"] == nil then
            break
        end
        for i = 1, #result["result"] do
            local tmpNode = result["result"][i][direction]
            if mapNode[tmpNode["name"]] == true then
                goto continue
            end

            startIndex = startIndex + 1
            node = {}
            node["id"] = startIndex
            node["text"] = tmpNode["name"]
            node["node"] = tmpNode
            mapNode[tmpNode["name"]] = true
            node["parent_id"] = indexStackNode["id"]
            table.insert(nodeList,node)
            table.insert(stack, tmpNode)
            table.insert(stackNode,node)
            ::continue::
        end
        indexNode = table.remove(stack)
        indexStackNode = table.remove(stackNode)

    end
    return nodeList
end


return M
