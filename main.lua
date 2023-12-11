local function read_file(path)
    local file = io.open(path, "r")
    if file then
        local text = file:read("*all")
        file:close()
        return text
    else
        return nil
    end
end

local function get_blocks(text)
    local blocks = {}
    local regex = "```%s*([^%s]+)%s*([^%s]*)%s*\n(.-)```"

    for lang, id, body in text:gmatch(regex) do
        local block = {
            lang = lang,
            id = id,
            body = body
        }
        table.insert(blocks, block)
    end

    return blocks
end

local function find_snippet(blocks, id)
    for _, block in ipairs(blocks) do
        if block.id == "#" .. id then
            return block
        end
    end

    return nil
end

local function new_snippet(block)
    local file_name = SNIPPETS[block.lang].name
    local file = io.open(file_name, "w")
    if file then
        file:write(block.body)
        file:close()
    end
end

local function run_snippet(path, id)
    require("cfg")
    local blocks = get_blocks(read_file(path))
    local block = find_snippet(blocks, id)

    if block then
        new_snippet(block)
        os.execute(SNIPPETS[block.lang].script)
    end
end

local function main()
    local mode = arg[1]
    local path = arg[2]
    local snippet_id

    if mode == "snip" then
        snippet_id = arg[3]
        run_snippet(path, snippet_id)
    end
end

main()