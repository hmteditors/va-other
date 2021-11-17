### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 766e600d-200c-4421-9a21-a8fa0aa6a4a7
begin	
	using PlutoUI
	using CitableText
	using CitableCorpus
	using CitableObject
	using CitablePhysicalText
	using CitableTeiReaders
	using CSV
	using DataFrames
	using EditionBuilders
	using EditorsRepo
	using HTTP
	#using Lycian
	using Markdown
	using Orthography
	using ManuscriptOrthography
	using PolytonicGreek
	using Unicode

	using CitableImage
end


# ╔═╡ 617ce64a-d7b1-4f66-8bd0-f7a240a929a7
 md"""$(@bind loadem Button("Load/reload data"))"""

# ╔═╡ b158c0f7-f519-4df5-b776-b2c4060717a7
html"""
<span class="advice">Click <code>Load/reload data</code> to initialize app after it completely loads.  The first time you select a passage, it will take a moment to compile all the display functions.</span>
"""

# ╔═╡ be7cddab-9888-401b-962e-8ee6207d1c34
html"""
<br/><br/><br/><br/>
<hr/><hr/>
<p class="advice">You can ignore the rest of this notebook unless you're interested in how it works.</p>
<hr/><hr/>
"""

# ╔═╡ 3fe231b9-df28-4120-8961-679dcd45fadd
md">CSS"

# ╔═╡ 0094ef89-a479-4822-a47f-527545b34a0e
md"""> Settings and user-interface elements
"""

# ╔═╡ e099bf98-fbe3-4ad1-965a-3b94ca01d0e4
menu = [
		"" => "",
		("1r","Homer") => "Life of Homer (1r)",
		("1v","Homer") => "Life of Homer continued (1v)",
		nothing => "[Cypria: lost in VA]",
		("6r", "aethiopis") => "Aethiopis (6r)",
		("6r", "iliasparva") => "Little Iliad (6r)",
		("6v", "iliasparva") => "Little Iliad continued (6v)",
		("6v", "iliupersis") => "Sack of Troy (6v)",
		("4r", "iliupersis") => "Sack of Troy continued (4r)",
		("4r", "nostoi") => "Returns (Nostoi) (4r)",
		("4r", "telegonia") => "Telegonia (4r)",
		("4v", "telegonia") => "Telegonia continued (4v)",
	
	
	]


# ╔═╡ 15050388-e00b-408f-aca2-1e3a42051d6d
md"""Select passage to display: $(@bind ecloga Select(menu))"""

# ╔═╡ a43a0bc8-9648-4c9b-818f-a05de27df7ed
titles = Dict(
	"Homer" => "Life of Homer",
	 "aethiopis" => "Aethiopis",
	"iliasparva" => "Little Iliad",
	"iliupersis" => "Sack of Troy",
	"nostoi" => "Returns (Nostoi)",
	"telegonia" => "Telegonia"
)
		

# ╔═╡ 01b309e7-67e2-49c8-a67c-3b045fe2e629
fontmenu = [
	"Fira Sans",
	"Alegreya Sans SC",
	"Arimo",
	"Inter",
	"M PLUS 1",
	"Roboto"
]

# ╔═╡ 52778337-e472-4cdc-b0ae-e8062cf1ef06
md"""Font for Greek display: $(@bind font Select(fontmenu, default="M PLUS 1"))"""

# ╔═╡ efb6dd1a-a87c-4aae-8cad-31f84e333512
greekcss = """
<style>
	@import url('https://fonts.googleapis.com/css2?family=Alegreya+Sans+SC&family=Arimo&family=Fira+Sans:ital@0;1&family=Inter&family=M+PLUS+1p&family=Roboto:ital@0;1&display=swap');
	.greek {
		font-family: '$(font)', sans-serif;
	}

figure {
    display: inline-block;
    margin: 20px; /* adjust as needed */
	
}
figure img {
    vertical-align: top;
	margin-left: 20px;
}
figure figcaption {
    text-align: center;
	font-style: italic;
}

.advice {
	text-align: center;
	color: silver;
}

</style>
"""

# ╔═╡ 00c739c4-3f9a-4a2d-92de-6fba03d5f08e
parsedcss = HTML(greekcss)

# ╔═╡ 7e400dbc-a86a-42d4-a872-864b237b0771
vapages = Cite2Urn("urn:cite2:hmt:msA.v1:")

# ╔═╡ 03dc3687-0e1a-4796-912d-3d8faf23f3c7
proclus = CtsUrn("urn:cts:greekLit:tlg4036.tlg023.va:")

# ╔═╡ b77fa921-123d-460f-a599-11f1eb0ad598
thumbht = 100

# ╔═╡ d86c76f8-12fe-44e4-ae90-de777597b650
md"> Display functions"

# ╔═╡ 26a10ae9-446b-444e-bfda-772290129124
md"> Repository and image services"

# ╔═╡ 1dbfc4bc-2cb0-43d0-8742-0ce5520845e6
# Create EditingRepository for this notebook's repository
# Since the notebook is in the `notebooks` subdirectory of the repository,
# we can just use the parent directory (dirname() in julia) for the
# root directory.
function editorsrepo() 
    repository(dirname(pwd()))
end

# ╔═╡ 4f145196-0723-4e2b-b8af-466649f5e6a9
# Format HTML <p> for a single passage.
function formatpsg(psgu) 
	reading = diplomatic_passagetext(editorsrepo(), psgu)
	opening = "<p class=\"greek\">"
	closing = "</p>"
	hdg = "<b>$(passagecomponent(psgu))</b>"
	join([opening, hdg, reading, closing], " ")
end

# ╔═╡ 5369d042-93a4-4b78-8bb2-46967d136092
function ict()
	"http://www.homermultitext.org/ict2/?"
end

# ╔═╡ 6b7906d2-54db-40ff-ad62-76ea839483bd
function iiifsvc()
	IIIFservice("http://www.homermultitext.org/iipsrv",
	"/project/homer/pyramidal/deepzoom")
end

# ╔═╡ 5157fa58-9c83-464d-acfb-8e9460420955
# Compose markdown for thumbnail images linked to ICT with overlay of all
# DSE regions.
function linkedPage(urn, repo)
    # Get DSE for relevant passages:
	pagerows = eachrow(surfaceDse(repo, urn))
	txturn = addpassage(proclus, ecloga[2])
	textrows = filter(row -> urncontains(txturn, row.passage), pagerows)

	# Group images with ROI into a dictionary keyed by image
	# WITHOUT RoI.
	grouped = Dict()
	for row in textrows 
		trimmed = CitableObject.dropsubref(row.image)
		if haskey(grouped, trimmed)
			push!(grouped[trimmed], row.image)
		else
			grouped[trimmed] = [row.image]
		end
	end

	# Now cycle through all images, and build up link to  ICT
	htmlstrings = []
	for k in keys(grouped)
		thumb = htmlImage(k, iiifsvc(); ht = thumbht)
		params = map(img -> string("urn=", img.urn, "&"), grouped[k]) 
		lnk = ict() * join(params,"") 
		#push!(htmlstrings, "[$(thumb)]($(lnk))")
		push!(htmlstrings, 	string("<a href=\"", lnk, "\">", thumb, "</a>"))
		
	end
	join(htmlstrings, " ")
	
end

# ╔═╡ 17e1e1e8-8d23-4951-bd2d-657b6f3e50ce
function readme(tup)
	txturn = addpassage(proclus, tup[2])
	pgurn = addobject(vapages, tup[1])
	pagedse = surfaceDse(editorsrepo(),  pgurn)
	texturns = pagedse[! , :passage]
	textchoice = filter(u -> urncontains(txturn, u), texturns)
	title = titles[tup[2]]
	psgs = []
	for txturn in textchoice
		push!(psgs, formatpsg(txturn))
	end
	linkedimg = linkedPage(pgurn, editorsrepo())
	
	"""<h2 class="greek"> Page $(objectcomponent(pgurn)): <i>$(title)</i></h2> 
	<figure>$(linkedimg)
	<figcaption>See passages</br>highlighted on page</figcaption>
	</figure>
		
	
	$(join(psgs, "\n\n"))
	
	"""
end

# ╔═╡ 2bcf30fd-8c7b-4434-9fdf-2f611272f1f8
if isnothing(ecloga)
	md"Cypria does not exist in VA"
elseif isempty(ecloga)
	html"<span class=\"advice\">(make a selection)</span>"
else
	HTML(readme(ecloga))
end

# ╔═╡ 542976d1-24e6-48ea-9d2b-3b0b21562ade
md"> Substitute Pkg.TOML reader"

# ╔═╡ b6eec8b0-0c92-49f2-bb27-7b50d45dc9fd
# Read MID.toml into a dictionary, since using the normal Pkg TOML parser
# would turn off Pluto package management!
function tomldict(f)
	loadem
	dict = Dict()
	#lns = readlines(joinpath(pwd(), "MID.toml"))
	lns = readlines(f)
	for ln in lns
		cols = split(ln, "=")
		if length(cols) == 2
			val = replace(cols[2],"\"" => "") |> strip
			key = strip(cols[1])
			dict[key] = val
		end
	end
	dict
end

# ╔═╡ 5861290e-60b1-48e8-b39f-08f4d10095c5
middict = begin
	loadem
	tomldict(joinpath(pwd(), "MID.toml"))
end

# ╔═╡ 17ebe116-0d7f-4051-a548-1573121a33c9
begin
	loadem
	github = middict["github"]
	projectname =	middict["projectname"] 

	pg = string(
		
		"<blockquote  class='splash'>",
		"<div class=\"center\">",
		"<h2>Proclus reader",
		"</h2>",
		"</div>",
		"<ul>",
		"<li>Texts in this github repository:  ",
		"<a href=\"" * github * "\">" * github * "</a>",
		"</li>",
		
		"<li>Repository cloned locally in: ",
		"<strong>",
		dirname(pwd()),
		"</strong>",
		"</li>",
		"</ul>",

		"</blockquote>"
		)
	
	HTML(pg)
	
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableImage = "17ccb2e5-db19-44b3-b354-4fd16d92c74e"
CitableObject = "e2b2f5ea-1cd8-4ce8-9b2b-05dad64c2a57"
CitablePhysicalText = "e38a874e-a7c2-4ff3-8dea-81ae2e5c9b07"
CitableTeiReaders = "b4325aa9-906c-402e-9c3f-19ab8a88308e"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
EditionBuilders = "2fb66cca-c1f8-4a32-85dd-1a01a9e8cd8f"
EditorsRepo = "3fa2051c-bcb6-4d65-8a68-41ff86d56437"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
ManuscriptOrthography = "c7d01213-112e-44c9-bed3-ac95fd3728c7"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
Orthography = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PolytonicGreek = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"
Unicode = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[compat]
CSV = "~0.9.11"
CitableCorpus = "~0.8.0"
CitableImage = "~0.3.0"
CitableObject = "~0.8.4"
CitablePhysicalText = "~0.3.3"
CitableTeiReaders = "~0.7.3"
CitableText = "~0.11.2"
DataFrames = "~1.2.2"
EditionBuilders = "~0.6.2"
EditorsRepo = "~0.14.5"
HTTP = "~0.9.16"
ManuscriptOrthography = "~0.2.2"
Orthography = "~0.15.1"
PlutoUI = "~0.7.19"
PolytonicGreek = "~0.13.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0bc60e3006ad95b4bb7497698dd7c6d649b9bc06"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AtticGreek]]
deps = ["DocStringExtensions", "Documenter", "Orthography", "PolytonicGreek", "Test", "Unicode"]
git-tree-sha1 = "c963e50843b6bfc52c2516c93db645b0b13f42ef"
uuid = "330c8319-f7ed-461a-8c52-cee5da4c0892"
version = "0.7.3"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "49f14b6c56a2da47608fe30aed711b5882264d7a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.11"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

[[CitableBase]]
deps = ["DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "e8f2177735ca2801bb0039ed4df964f64103331e"
uuid = "d6f014bd-995c-41bd-9893-703339864534"
version = "5.0.0"

[[CitableCorpus]]
deps = ["CitableBase", "CitableText", "CiteEXchange", "DataFrames", "DocStringExtensions", "Documenter", "HTTP", "Test"]
git-tree-sha1 = "a1235ef764c5ac613ceffc0814302960d300ac7c"
uuid = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
version = "0.8.0"

[[CitableImage]]
deps = ["CitableBase", "CitableObject", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "f36b7555da8571b2d2aef3b0875338d2befe6fd1"
uuid = "17ccb2e5-db19-44b3-b354-4fd16d92c74e"
version = "0.3.0"

[[CitableObject]]
deps = ["CitableBase", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "b3c5e5229b3197c5bd9124ae099d38f58652bca5"
uuid = "e2b2f5ea-1cd8-4ce8-9b2b-05dad64c2a57"
version = "0.8.4"

[[CitableParserBuilder]]
deps = ["CSV", "CitableBase", "CitableCorpus", "CitableObject", "CitableText", "DataStructures", "DocStringExtensions", "Documenter", "HTTP", "Orthography", "Test", "TypedTables"]
git-tree-sha1 = "4d980bc9e4cf3b8041b0f44f7e0f0fb84e7e3b0f"
uuid = "c834cb9d-35b9-419a-8ff8-ecaeea9e2a2a"
version = "0.21.1"

[[CitablePhysicalText]]
deps = ["CSV", "CitableObject", "CitableText", "CiteEXchange", "DataFrames", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "74e0be40e4a855335ee2e525a1443d2b1df70fb0"
uuid = "e38a874e-a7c2-4ff3-8dea-81ae2e5c9b07"
version = "0.3.3"

[[CitableTeiReaders]]
deps = ["CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "EzXML", "Test"]
git-tree-sha1 = "18945dd65385daa4e84bf5d0b1fb12238684ba91"
uuid = "b4325aa9-906c-402e-9c3f-19ab8a88308e"
version = "0.7.3"

[[CitableText]]
deps = ["CitableBase", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "a5be6a87057390dc14a50cd06887002cd3c0115a"
uuid = "41e66566-473b-49d4-85b7-da83b66615d8"
version = "0.11.2"

[[CiteEXchange]]
deps = ["CSV", "CitableObject", "DocStringExtensions", "Documenter", "HTTP", "Test"]
git-tree-sha1 = "26156894cf3a817910adf9cc59c7d4625af72f67"
uuid = "e2e9ead3-1b6c-4e96-b95f-43e6ab899178"
version = "0.4.6"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Dictionaries]]
deps = ["Indexing", "Random"]
git-tree-sha1 = "43ae37eac34e76ac97d1a7db28561243e7242461"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.15"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Documenter]]
deps = ["ANSIColoredPrinters", "Base64", "Dates", "DocStringExtensions", "IOCapture", "InteractiveUtils", "JSON", "LibGit2", "Logging", "Markdown", "REPL", "Test", "Unicode"]
git-tree-sha1 = "f425293f7e0acaf9144de6d731772de156676233"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "0.27.10"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EditionBuilders]]
deps = ["CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "EzXML", "Test"]
git-tree-sha1 = "de8173ba8eea4a9167f5a44bbbfa2a53a31e3420"
uuid = "2fb66cca-c1f8-4a32-85dd-1a01a9e8cd8f"
version = "0.6.2"

[[EditorsRepo]]
deps = ["AtticGreek", "CSV", "CitableBase", "CitableCorpus", "CitableObject", "CitablePhysicalText", "CitableTeiReaders", "CitableText", "CiteEXchange", "DataFrames", "DocStringExtensions", "Documenter", "EditionBuilders", "Lycian", "ManuscriptOrthography", "Orthography", "PolytonicGreek", "Test"]
git-tree-sha1 = "040d82a9f8e0717603c3811e22aef038706c9803"
uuid = "3fa2051c-bcb6-4d65-8a68-41ff86d56437"
version = "0.14.5"

[[EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[FilePathsBase]]
deps = ["Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "5440c1d26aa29ca9ea848559216e5ee5f16a8627"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.14"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "19cb49649f8c41de7fea32d089d37de917b553da"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.0.1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterableTables]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Requires", "TableTraits", "TableTraitsUtils"]
git-tree-sha1 = "70300b876b2cebde43ebc0df42bc8c94a144e1b4"
uuid = "1c8ee90f-4401-5389-894e-7a04a3dc0f4d"
version = "1.0.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Lycian]]
deps = ["CSV", "CitableCorpus", "CitableObject", "CitableParserBuilder", "CitableText", "DataFrames", "DocStringExtensions", "Documenter", "HTTP", "Orthography", "Query", "Test"]
git-tree-sha1 = "aca19e3a573bc0604982ee2f74066671920e85af"
uuid = "7c215dd3-d1b4-4517-b6c6-0123f1059a20"
version = "0.5.3"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[ManuscriptOrthography]]
deps = ["DocStringExtensions", "Documenter", "Orthography", "PolytonicGreek", "Test", "Unicode"]
git-tree-sha1 = "e881995ed5ab21cf300a1f3464465937483c4735"
uuid = "c7d01213-112e-44c9-bed3-ac95fd3728c7"
version = "0.2.2"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Orthography]]
deps = ["CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "OrderedCollections", "StatsBase", "Test", "TypedTables", "Unicode"]
git-tree-sha1 = "ab69ef19b53907704238b4113d9fb9a65c2d2774"
uuid = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
version = "0.15.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "e071adf21e165ea0d904b595544a8e514c8bb42c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.19"

[[PolytonicGreek]]
deps = ["DocStringExtensions", "Documenter", "Orthography", "Test", "Unicode"]
git-tree-sha1 = "603debfd221e9ae14ea0fbad4c0f3aaf3062d326"
uuid = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"
version = "0.13.2"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Query]]
deps = ["DataValues", "IterableTables", "MacroTools", "QueryOperators", "Statistics"]
git-tree-sha1 = "a66aa7ca6f5c29f0e303ccef5c8bd55067df9bbe"
uuid = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
version = "1.0.0"

[[QueryOperators]]
deps = ["DataStructures", "DataValues", "IteratorInterfaceExtensions", "TableShowUtils"]
git-tree-sha1 = "911c64c204e7ecabfd1872eb93c49b4e7c701f02"
uuid = "2aef5ad7-51ca-5a8f-8e88-e75cf067b44b"
version = "0.9.3"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "f45b34656397a1f6e729901dc9ef679610bd12b5"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.8"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SplitApplyCombine]]
deps = ["Dictionaries", "Indexing"]
git-tree-sha1 = "dec0812af1547a54105b4a6615f341377da92de6"
uuid = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
version = "1.2.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableShowUtils]]
deps = ["DataValues", "Dates", "JSON", "Markdown", "Test"]
git-tree-sha1 = "14c54e1e96431fb87f0d2f5983f090f1b9d06457"
uuid = "5e66a065-1f0a-5976-b372-e0b8c017ca10"
version = "0.2.5"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[TypedTables]]
deps = ["Adapt", "Dictionaries", "Indexing", "SplitApplyCombine", "Tables", "Unicode"]
git-tree-sha1 = "f91a10d0132310a31bc4f8d0d29ce052536bd7d7"
uuid = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"
version = "1.4.0"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─766e600d-200c-4421-9a21-a8fa0aa6a4a7
# ╟─17ebe116-0d7f-4051-a548-1573121a33c9
# ╟─b158c0f7-f519-4df5-b776-b2c4060717a7
# ╟─617ce64a-d7b1-4f66-8bd0-f7a240a929a7
# ╟─52778337-e472-4cdc-b0ae-e8062cf1ef06
# ╟─15050388-e00b-408f-aca2-1e3a42051d6d
# ╟─2bcf30fd-8c7b-4434-9fdf-2f611272f1f8
# ╟─be7cddab-9888-401b-962e-8ee6207d1c34
# ╟─3fe231b9-df28-4120-8961-679dcd45fadd
# ╟─00c739c4-3f9a-4a2d-92de-6fba03d5f08e
# ╟─efb6dd1a-a87c-4aae-8cad-31f84e333512
# ╟─0094ef89-a479-4822-a47f-527545b34a0e
# ╟─e099bf98-fbe3-4ad1-965a-3b94ca01d0e4
# ╟─a43a0bc8-9648-4c9b-818f-a05de27df7ed
# ╟─01b309e7-67e2-49c8-a67c-3b045fe2e629
# ╟─7e400dbc-a86a-42d4-a872-864b237b0771
# ╟─03dc3687-0e1a-4796-912d-3d8faf23f3c7
# ╟─b77fa921-123d-460f-a599-11f1eb0ad598
# ╟─d86c76f8-12fe-44e4-ae90-de777597b650
# ╟─4f145196-0723-4e2b-b8af-466649f5e6a9
# ╟─5157fa58-9c83-464d-acfb-8e9460420955
# ╟─17e1e1e8-8d23-4951-bd2d-657b6f3e50ce
# ╟─26a10ae9-446b-444e-bfda-772290129124
# ╟─1dbfc4bc-2cb0-43d0-8742-0ce5520845e6
# ╟─5369d042-93a4-4b78-8bb2-46967d136092
# ╟─6b7906d2-54db-40ff-ad62-76ea839483bd
# ╟─542976d1-24e6-48ea-9d2b-3b0b21562ade
# ╟─b6eec8b0-0c92-49f2-bb27-7b50d45dc9fd
# ╟─5861290e-60b1-48e8-b39f-08f4d10095c5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
