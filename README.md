Minetest Lua API Completer for Vim
==================================
Hello!
I'm a big fan of Minetest game and I'd like to make mods to it.
But I haven't found any auto-completer for Minetest's Modding API, so I decided to write one for Vim by myself :)

Here's what I've got for now:

![Demonstration of the plugin](https://cloud.githubusercontent.com/assets/19591977/17446253/0a2d17cc-5b51-11e6-9126-9845ca8f1093.gif)

And this is usage of this plugin with Neocomplete:

![Vim Minetest API Completer + Neocomplete](https://cloud.githubusercontent.com/assets/19591977/17446259/0f74b2c6-5b51-11e6-8469-4bcc245bcc68.gif)

This plugin uses some regexps to retrieve information about API functions from *lua_api.txt* file and provides completion based on
it.

**Note:** This algorithm is not perfect, so the plugin would miss some functions (for example, if their definition in *lua_api.txt*
has broken parentheses or \` sign in wrong place)

Also the plugin can complete only "global" functions, it can't complete methods, because it doesn't know anything about object's
type. 

Installation
------------
**Note:** This plugin requires **Vim >= 7.0** compiled with **+lua** feature. To check your version of vim, execute
`:echo version`
and to check if your vim supports Lua, execute
`:echo has('lua')`

If you use Vundle, just add the following line in your **.vimrc** (or **_vimrc** if you're on Windows) between `call vundle#begin()` and `call vundle#end()` lines:  
`Plugin 'DraggonFantasy/vim-minetest-api'`

If you're using another plugin manager, please refer to it's documentation. If you don't use any - install one. Really. 
Vim Plugin managers are amazing thing :)

Next, you need to provide path to **lua_api.txt** to the plugin. To do this, add the following line to your **.vimrc**:
`let g:MinetestApiCompleter_api_location = "`**(PATH)**`"`  
Where **(PATH)** is path to your *lua_api.txt*.  
For example:  
`let g:MinetestApiCompleter_api_location = "/opt/minetest/doc/lua_api.txt"`

Using
-----
Minetest Lua API Completer uses custom omnifunc, so to call a completion window you need to press **\<Ctrl-x\>** and then **\<Ctrl-o\>**.
To move in completion list you can use **\<Ctrl-n\>** and **\<Ctrl-p\>** or arrow keys.  
Or you can use some plugin, that will open an omni completion window as-you-type.
