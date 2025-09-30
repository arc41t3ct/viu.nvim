local M = {}

local report_start = vim.health.start or vim.health.report_start
local check_executable = vim.fn.executable
local report_ok = vim.health.ok or vim.health.report_ok
local report_error = vim.health.error or vim.health.report_error
local report_info = vim.health.info or vim.health.report_info

M.check = function()
  report_start("viu.nvim health check")
  if check_executable("viu") == 1 then
    report_ok("viu executable found")
  else
    report_error("viu executable not found")
    report_info("Can be installed with cargo: cargo install viu")
  end
end

return M
