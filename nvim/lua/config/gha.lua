-- Path helpers for GitHub Actions files. Workflows live in .github/workflows/;
-- composite actions are named action.yml/action.yaml and can sit anywhere in a repo.
local M = {}

function M.is_workflow(path)
  return path:find('/%.github/workflows/') ~= nil
end

function M.is_action(path)
  local name = vim.fs.basename(path)
  return name == 'action.yml' or name == 'action.yaml'
end

function M.is_gha(path)
  return M.is_workflow(path) or M.is_action(path)
end

return M
