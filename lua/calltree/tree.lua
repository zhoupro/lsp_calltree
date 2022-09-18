local M = {}
local NuiTree = require("nui.tree")
local lsp = require("calltree.lsp")

function M.BuildTree(nodePreList)
    local nodeList = M.ConvertNodeList(nodePreList)
    local idNodeMap = {}
    local idNodeRootMap = {}

    for i = 1, #nodeList do
        idNodeMap[nodeList[i]["cid"]] = nodeList[i]
        if nodeList[i]["parent"] == nil then
            table.insert(idNodeRootMap,nodeList[i]["cid"])
        end
    end

    local cur_node = table.remove(idNodeRootMap)
    while cur_node ~= nil do
        for _, value in pairs(idNodeMap) do
            if value["parent"] == cur_node then
                table.insert(idNodeMap[cur_node]["__children"], value)
                table.insert(idNodeRootMap, value["cid"])
            end
        end
        cur_node = table.remove(idNodeRootMap)
    end
    return {idNodeMap[lsp.GetStartIndex()]}

end

function M.ConvertNodeList(nodeOriList)
    local nodeList = {}

    for i = 1, #nodeOriList do
        local node = NuiTree.Node({
            text=nodeOriList[i]["text"],
            node= nodeOriList[i]["node"],
            cid = nodeOriList[i]["id"],
            parent = nodeOriList[i]["parent_id"]

        },{})
        table.insert(nodeList, node)
    end
    return nodeList

end

return M
