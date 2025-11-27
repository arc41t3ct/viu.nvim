---@diagnostic disable: missing-parameter
local M = {}

local async = require("plenary.async")

local config = require("viu.config")
local utils = require("viu.utils")
local options = require("viu.options")

local global_opts = nil

---@diagnostic disable-next-line: unused-local
local get_image_data_sync = function(buf_path, width, height, opts, callback)
  local command = { "viu", buf_path, "--width", width, "--height", height }

  vim.fn.jobstart(command, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        table.remove(data)
        callback(data)
      end
    end,
  })
end

local get_image_data = function(...)
  return async.wrap(get_image_data_sync, 5)(...)
end

local on_image_open = function()
  local buf_id = 0

  local buf_path = vim.api.nvim_buf_get_name(buf_id)

  local width, height, horizontal_padding, vertical_padding =
      utils.calculate_ascii_width_height(buf_id, buf_path, global_opts)

  options.set_options_before_render(buf_id)
  utils.buf_clear(buf_id)

  local label = utils.create_label(buf_path, width, horizontal_padding)

  local ascii_data = get_image_data(buf_path, width, height, global_opts)
  utils.buf_insert_data_with_padding(buf_id, ascii_data, horizontal_padding, vertical_padding, label, global_opts)

  options.set_options_after_render(buf_id)
end

function M.setup(user_opts)
  user_opts = user_opts or {}
  global_opts = vim.tbl_deep_extend("force", config.DEFAULT_OPTS, user_opts)

  local image_group = vim.api.nvim_create_augroup("nonvim", { clear = false })
  vim.api.nvim_create_autocmd("BufRead", {
    pattern = config.SUPPORTED_FILE_PATTERNS,
    group = image_group,
    callback = function()
      async.run(function()
        on_image_open()
      end)
    end,
  })
end

return M
