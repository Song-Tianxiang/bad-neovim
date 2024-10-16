local M = {}

local function notify_output(msg, sc, level)
	local function remove_shell_color(s)
		return tostring(s):gsub("\x1B%[[0-9;]+m", "")
	end
	vim.notify(
		table.concat({
			msg,
			sc and "stderr: " .. remove_shell_color(sc.stderr),
			sc and "stdout: " .. remove_shell_color(sc.stdout),
		}, "\n"),
		level
	)
end

local function exec(cmd, opts)
	local ok, so_or_err = pcall(vim.system, cmd, opts)
	if not ok then
		return {
			code = 1,
			signal = 0,
			stderr = ([[
Failed to execute:
%s
%s]]):format(table.concat(cmd, " "), so_or_err),
		}
	end
	return so_or_err:wait()
end

local function set_up_luarocks(path)
	local tempdir = vim.fs.joinpath(vim.fn.stdpath("run"), ("luarocks-%X"):format(math.random(256 ^ 7)))

	local sc = exec({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/luarocks/luarocks.git",
		tempdir,
	})

	if sc.code ~= 0 then
		notify_output("Cloning luarocks failed: ", sc, vim.log.levels.ERROR)
		return false
	end

	sc = exec({
		"sh",
		"configure",
		"--prefix=" .. path,
		"--lua-version=5.1",
		"--force-config",
	}, {
		cwd = tempdir,
	})

	if sc.code ~= 0 then
		notify_output("Configuring luarocks failed.", sc, vim.log.levels.ERROR)
		return false
	end

	sc = exec({
		"make",
		"install",
	}, {
		cwd = tempdir,
	})

	if sc.code ~= 0 then
		notify_output("Installing luarocks failed.", sc, vim.log.levels.ERROR)
		return false
	end

	return true
end

M.install = function(pkg)
	local cmd = {
		M.luarocks_binary,
		"--lua-version=5.1",
		"--tree=" .. M.rocks_root,
		"--server='https://nvim-neorocks.github.io/rocks-binaries/'",
		"install",
		"--force-fast",
		pkg,
	}
	vim.notify("Installing " .. pkg)
	vim.system(cmd, { text = true }, function(obj)
		if obj.code ~= 0 then
			vim.notify("Installing luarocks " .. pkg .. " failed: " .. obj.stderr, vim.log.levels.ERROR)
		else
			vim.notify("Installing luarocks " .. pkg .. " succeed.", vim.log.levels.INFO)
		end
	end)
end

M.setup = function(opts)
	opts = opts or {}
	M.rocks_root = opts.rocks_root or vim.fs.joinpath(vim.fn.stdpath("data"), "rocks")
	M.luarocks_binary = opts.luarocks_binary or vim.fs.joinpath(M.rocks_root, "bin", "luarocks")

	if not vim.uv.fs_stat(M.luarocks_binary) then
		assert(set_up_luarocks(M.rocks_root), "failed to install luarocks! Please try again :)")
	end
	vim.env.PATH = vim.fs.dirname(M.luarocks_binary) .. ":" .. vim.env.PATH

	local luarocks_path = {
		vim.fs.joinpath(M.rocks_root, "share", "lua", "5.1", "?.lua"),
		vim.fs.joinpath(M.rocks_root, "share", "lua", "5.1", "?", "init.lua"),
	}
	package.path = package.path .. ";" .. table.concat(luarocks_path, ";")

	local luarocks_cpath = {
		vim.fs.joinpath(M.rocks_root, "lib", "lua", "5.1", "?.so"),
		vim.fs.joinpath(M.rocks_root, "lib64", "lua", "5.1", "?.so"),
	}
	package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")
	vim.api.nvim_create_user_command("RocksInstall", function(opt)
		M.install(opt.fargs[1])
	end, { nargs = 1 })
end

return M
