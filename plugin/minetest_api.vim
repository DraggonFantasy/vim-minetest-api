"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin:        Vim Minetest Api Completer
" Author:        Boris Varer aka DraggonFantasy <thedraggonfantasy@gmail.com>
" URL:           https://github.com/DraggonFantasy/vim-minetest-api
" License:       MIT {{{
" Permission is hereby granted, free of charge,
" to any person obtaining a copy of this software
" and associated documentation files (the "Software"),
" to deal in the Software without restriction,
" including without limitation the rights to use,
" copy, modify, merge, publish, distribute, sublicense,
" and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished
" to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice
" shall be included in all copies or substantial portions
" of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
" OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT.
" IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
" ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
" TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
" OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"
" }}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""" Section: Initialization {{{1
if exists("g:loaded_minetest_api_completer")
    finish
endif
if v:version < 700
    echoerr "Minetest API Completer requires Vim >= 7"
    finish
endif
if !has("lua")
    echoerr "Minetest API Completer requires Vim compiled with +lua"
    finish
endif
let g:loaded_minetest_api_completer = 1

"" Subsection: Setup options {{{2
if !exists("g:MinetestApiCompleter_api_location")
    echoerr "Please provide path to lua_api.txt file in your .vimrc in variable g:MinetestApiCompleter_api_location"
    finish
endif
if !exists("g:MinetestApiCompleter_max_matches")
    let g:MinetestApiCompleter_max_matches = 10
endif
if !exists("g:MinetestApiCompleter_complete_args")
    let g:MinetestApiCompleter_complete_args = 0
endif
"}}}2

"}}}1

"""Section: Retrieving lua api from lua_api.txt {{{
lua << byelua

-- NOTE: This is quick, simple and dirty solution (but though it works and is usable)
-- This doesn't not work (yet?) with api lines like:
--    * `minetest.get_player_privs(name) -> {priv1=true,...}`
-- The script will just omit such lines
-- (but it would work if replace that string with:
--    * `minetest.get_player_privs(name)` -> {priv1=true,...}
-- )

local func_identifier_pattern = "[_%a][_%w]*[%.:]?[_%w]*" 
local args_pattern = "[%+%-%.:\"'{}%[%]=_,%s%w%(%)]*" -- This is just set of characters that *may* be used in args 
-- NOTE: args_pattern has ( and ) characters, because there may be func(blablabla) arguments

function retrieve_api(filename)
    local results = {}
    local api_func_pattern = "^%s*%*%s*`(" .. func_identifier_pattern .. "%(" .. args_pattern .. "%))`" 
   
    local func_name = nil
    local func_indent = 0
    local func_docs = ""
    for line in io.lines(filename) do
        local line_indent = get_indent_level(line)
        -- If the indentation of current line is same as the function we process,
        -- then it's a next function
        -- 
        -- BUT if the indentiton of line is deeper,
        -- then it's a documentation for current function
        
        if line_indent == func_indent then
            local i, j, func = string.find(line, api_func_pattern)
            if i ~= nil then
                if func_name ~= nil then
                    results[func_name] = func_docs -- Push previous function
                end

                func_name = func
                func_docs = func .. "\n" .. string.sub(line, j+1)
                if func_docs == nil then func_docs = "" end
            end
        elseif line_indent > func_indent then
            -- gsub() here trims spaces and removes star (*) from left,
            -- leaving only needed part of docs
            local docs = string.gsub(line, "^%s*%*?(.*)%s*$", "%1")
            func_docs = func_docs .. '\n' .. docs
        end
       
    end

    return results
end

function get_indent_level(line)
    local firstNonSpace = string.find(line, '%S')
    if firstNonSpace == nil then
        return 0
    end
    return firstNonSpace - 1
end

function file_exists(filename)
    local file = io.open(filename)
    if file ~= nil then
        io.close(file)
        return true
    else
        return false
    end
end

-- TODO: Optimize it?
function complete(base)
    if base == nil or base == "" then
        return vim.list() 
    end

    local maxMatchCount = vim.eval("g:MinetestApiCompleter_max_matches")
    local completeArgs  = vim.eval("g:MinetestApiCompleter_complete_args")
    local results = vim.list() -- {}
    for func,docs in pairs(api) do
        if string.match(func, "^" .. base) then
            local match = vim.dict()
            if completeArgs == 1 then
                match["word"] = func
            else
                match["abbr"] = func
                match["word"] = string.match(func, "^(" .. func_identifier_pattern .. ")") .. "("
            end
            match["info"] = docs
            match["menu"] = "MT"
            results:add( match )
            if #results >= maxMatchCount then
                break
            end
        end
    end

    return results
end


local filename = vim.eval("g:MinetestApiCompleter_api_location")
api = {}
if file_exists(filename) then
    api = retrieve_api(filename)
else
    vim.command("echoerr \"Couldn't find file at g:MinetestApiCompleter_api_location\"")
end

byelua

"}}}

function! MinetestApiCompleter_Complete(findstart, base)
    if a:findstart
        let line = getline('.')
        let start = col('.') - 1
        
        while start > 0 && line[start - 1] =~ '[a-zA-Z0-9.:_]'
            let start -= 1
        endwhile

        return start
    else
        let matches = luaeval("complete('" . a:base . "')")
        let results = {'words': matches}
        return results
    endif
endfunction
