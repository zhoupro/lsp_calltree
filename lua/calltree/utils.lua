-- copy from nvim lsp core
local M = {}

local api = vim.api
--- Utility function for getting the encoding of the first LSP client on the given buffer.
---@param bufnr (number) buffer handle or 0 for current, defaults to current
---@returns (string) encoding first client if there is one, nil otherwise
function M._get_offset_encoding(bufnr)
  local offset_encoding

  for _, client in pairs(vim.lsp.buf_get_clients(bufnr)) do
    if client.offset_encoding == nil then
      vim.notify_once(
        string.format(
          'Client (id: %s) offset_encoding is nil. Do not unset offset_encoding.',
          client.id
        ),
        vim.log.levels.ERROR
      )
    end
    local this_offset_encoding = client.offset_encoding
    if not offset_encoding then
      offset_encoding = this_offset_encoding
    elseif offset_encoding ~= this_offset_encoding then
      vim.notify(
        'warning: multiple different client offset_encodings detected for buffer, this is not supported yet',
        vim.log.levels.WARN
      )
    end
  end
end

--- Convert byte index to `encoding` index.
--- Convenience wrapper around vim.str_utfindex
---@param line string line to be indexed
---@param index number|nil byte index (utf-8), or `nil` for length
---@param encoding string utf-8|utf-16|utf-32|nil defaults to utf-16
---@return number `encoding` index of `index` in `line`
function M._str_utfindex_enc(line, index, encoding)
  if not encoding then
    encoding = 'utf-16'
  end
  if encoding == 'utf-8' then
    if index then
      return index
    else
      return #line
    end
  elseif encoding == 'utf-16' then
    local _, col16 = vim.str_utfindex(line, index)
    return col16
  elseif encoding == 'utf-32' then
    local col32, _ = vim.str_utfindex(line, index)
    return col32
  else
    error('Invalid encoding: ' .. vim.inspect(encoding))
  end
end

local _str_utfindex_enc = M._str_utfindex_enc

local function make_position_param(window, offset_encoding)
  window = window or 0
  local buf = api.nvim_win_get_buf(window)
  local row, col = unpack(api.nvim_win_get_cursor(window))
  offset_encoding = offset_encoding or M._get_offset_encoding(buf)
  row = row - 1
  local line = api.nvim_buf_get_lines(buf, row, row + 1, true)[1]
  if not line then
    return { line = 0, character = 0 }
  end

  col = _str_utfindex_enc(line, col, offset_encoding)

  return { line = row, character = col }
end

--- Creates a `TextDocumentPositionParams` object for the current buffer and cursor position.
---
---@returns `TextDocumentPositionParams` object
---@see https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocumentPositionParams
function M.make_position_params()
  local window =  0
  local buf = api.nvim_win_get_buf(window)
  local offset_encoding =  M._get_offset_encoding(buf)
  return {
    textDocument = M.make_text_document_params(buf),
    position = make_position_param(window, offset_encoding),
  }
end

--- Creates a `TextDocumentIdentifier` object for the current buffer.
---
---@param bufnr number|nil: Buffer handle, defaults to current
---@returns `TextDocumentIdentifier`
---@see https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocumentIdentifier
function M.make_text_document_params(bufnr)
  return { uri = vim.uri_from_bufnr(bufnr or 0) }
end






return M
