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
	using CitableImage
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
end


# ╔═╡ d2ff2f48-70ea-4837-a29d-1884eacebd61
function readme(pg,psg)
	md"""$(pg), $(psg)"""
end

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
		("4r", "nostoi") => "Nostoi (4r)",
		("4r", "telegonia") => "Telegonia (4r)",
		("4v", "telegonia") => "Telegonia continued (4v)",
	
	
	]


# ╔═╡ 15050388-e00b-408f-aca2-1e3a42051d6d
md"""$(@bind ecloga Select(menu))"""

# ╔═╡ 2bcf30fd-8c7b-4434-9fdf-2f611272f1f8
if isnothing(ecloga)
	md"Cypria does not exist in VA"
elseif isempty(ecloga)
	md""
else
	readme(ecloga[1], ecloga[2])
end

# ╔═╡ 03dc3687-0e1a-4796-912d-3d8faf23f3c7
proclus = CtsUrn("urn:cts:greekLit:tlg4036.tlg023.va:")

# ╔═╡ 617ce64a-d7b1-4f66-8bd0-f7a240a929a7
@bind loadem Button("Load/reload data")

# ╔═╡ ee2f04c1-42bb-46bb-a381-b12138e550ee
md"> ## Verification: DSE indexing"

# ╔═╡ 834a67df-8c8b-47c6-aa3e-20297576019a
md"""

### Verify *completeness* of indexing


*Check completeness of indexing by following linked thumb to overlay view in the Image Citation Tool*
"""

# ╔═╡ 8fcf792e-71eb-48d9-b0e6-e7e175628ccd
md"*Height of thumbnail image*: $(@bind thumbht Slider(150:500, show_value=true))"


# ╔═╡ 06bfa57d-2bbb-498e-b68e-2892d7186245
md"""
### Verify *accuracy* of indexing

*Check that diplomatic text and indexed image correspond.*


"""

# ╔═╡ ad541819-7d4f-4812-8476-8a307c5c1f87
md"""
*Maximum width of image*: $(@bind w Slider(200:1200, show_value=true))

"""

# ╔═╡ 3dd88640-e31f-4400-9c34-2adc2cd4c532
md"""

> ## Verification:  orthography

"""

# ╔═╡ ea1b6e21-7625-4f8f-a345-8e96449c0757
md"""

---

---


> ### Functions

You don't need to look at the rest of the notebook unless you're curious about how it works.  The following cells define the functions that retreive data from your editing repository, validate it, and format it for visual verification.

"""

# ╔═╡ fd401bd7-38e5-44b5-8131-dbe5eb4fe41b
md"> Formatting"


# ╔═╡ 066b9181-9d41-4013-81b2-bcc37878ab68
# Format HTML for EditingRepository's reporting on cataloging status.
function catalogcheck(editorsrepo::EditingRepository)
	cites = citation_df(editorsrepo)
	if filesmatch(editorsrepo, cites)
		md"✅XML files in repository match catalog entries."
	else
		htmlstrings = []
		
		missingfiles = filesonly(editorsrepo, cites)
		if ! isempty(missingfiles)
			fileitems = map(f -> "<li>" * f * "</li>", missingfiles)
			filelist = "<p>Uncataloged files found on disk: </p><ul>" * join(fileitems,"\n") * "</ul>"
			
			hdr = "<div class='warn'><h1>⚠️ Warning</h1>"
			tail = "</div>"
			badfileshtml = join([hdr, filelist, tail],"\n")
			push!(htmlstrings, badfileshtml)
		end
		
		notondisk = citedonly(editorsrepo, cites)
		if ! isempty(notondisk)
			nofilelist = "<p>Configured files not found on disk: </p><ul>" * join(fileitems , "\n") * "</ul>"
			hdr = "<div class='danger'><h1>🧨🧨 Configuration error 🧨🧨 </h1>" 
			tail = "</div>"
			nofilehtml = join([hdr, nofilelist, tail],"\n")
			push!(htmlstrings,nofilehtml)
		end
		HTML(join(htmlstrings,"\n"))
	end

end

# ╔═╡ 5cba9a9c-74cc-4363-a1ff-026b7b3999ea
#Create list of text labels for popupmenu
function surfacemenu(editorsrepo)
	loadem
	surfurns = EditorsRepo.surfaces(editorsrepo)
	surflist = map(u -> u.urn, surfurns)
	# Add a blank entry so popup menu can come up without a selection
	pushfirst!( surflist, "")
end

# ╔═╡ 1814e3b1-8711-4afd-9987-a41d85fd56d9
# Wrap tokens with invalid orthography in HTML tag
function formatToken(ortho, s)
	
	if isempty(strip(s))
		s
	elseif validstring(s, ortho)
			s
	else
		"""<span class='invalid'>$(s)</span>"""
	end
end

# ╔═╡ 3dd9b96b-8bca-4d5d-98dc-a54e00c75030
css = html"""
<style>
.splash {
	background-color: #f0f7fb;
}
.danger {
     background-color: #fbf0f0;
     border-left: solid 4px #db3434;
     line-height: 18px;
     overflow: hidden;
     padding: 15px 60px;
   font-style: normal;
	  }
.warn {
     background-color: 	#ffeeab;
     border-left: solid 4px  black;
     line-height: 18px;
     overflow: hidden;
     padding: 15px 60px;
   font-style: normal;
  }

  .danger h1 {
	color: red;
	}

 .invalidtoken {
	text-decoration-line: underline;
  	text-decoration-style: wavy;
  	text-decoration-color: red;
}
 .invalid {
	color: red;
	border: solid;
}
 .center {
text-align: center;
}
.highlight {
  background: yellow;  
}
.urn {
	color: silver;
}
  .note { -moz-border-radius: 6px;
     -webkit-border-radius: 6px;
     background-color: #eee;
     background-image: url(../Images/icons/Pencil-48.png);
     background-position: 9px 0px;
     background-repeat: no-repeat;
     border: solid 1px black;
     border-radius: 6px;
     line-height: 18px;
     overflow: hidden;
     padding: 15px 60px;
    font-style: italic;
 }


.instructions {
     background-color: #f0f7fb;
     border-left: solid 4px  #3498db;
     line-height: 18px;
     overflow: hidden;
     padding: 15px 60px;
   font-style: normal;
  }



</style>
"""

# ╔═╡ ec0f3c61-cf3b-4e4c-8419-176626a0888c
md"> Repository and image services"

# ╔═╡ 43734e4f-2efc-4f12-81ac-bce7bf7ada0a
# Create EditingRepository for this notebook's repository
# Since the notebook is in the `notebooks` subdirectory of the repository,
# we can just use the parent directory (dirname() in julia) for the
# root directory.
function editorsrepo() 
    repository(dirname(pwd()))
end

# ╔═╡ 35255eb9-1f54-4f9d-8c58-2d450e09dff9
begin
	loadem
	editorsrepo() |> catalogcheck
end

# ╔═╡ 8d407e7a-1201-4dd3-bddd-368362037205
md"""###  Choose a surface to verify

$(@bind surface Select(surfacemenu(editorsrepo())))
"""

# ╔═╡ 3cb683e2-5350-4262-b693-0cddee340254
# Compose HTML to display compliance with configured orthography
function orthography()
	if isempty(surface)
		md""
	else
	
		textconfig = citation_df(editorsrepo())
		catalog = textcatalog_df(editorsrepo())
		sdse = EditorsRepo.surfaceDse(editorsrepo(), Cite2Urn(surface))
		
		htmlrows = []
		for row in eachrow(sdse)
			tidy = EditorsRepo.baseurn(row.passage)
			ortho = orthographyforurn(textconfig, tidy)
			title = worktitle(catalog, row.passage)
			
			#chunks = normednodetext(editorsrepo(), row.passage) |> split
			chunks = graphemes(normalized_passagetext(editorsrepo(), tidy)) |> collect
			html = []
			for chunk in chunks
				push!(html, formatToken(ortho, chunk))
			end
			
			psg = passagecomponent(tidy)
			htmlrow =  string("<p><i>$title</>, <b>$psg</b> ", join(html), "</p>")
			push!(htmlrows,htmlrow)
		end
		HTML(join(htmlrows,"\n"))
	end
end

# ╔═╡ 3b04a423-6d0e-4221-8540-ad457d0bb65e
orthography()

# ╔═╡ 080b744e-8f14-406d-bdd2-fbcd3c1ec753
# Base URL for an ImageCitationTool
function ict()
	"http://www.homermultitext.org/ict2/?"
end

# ╔═╡ 806b3733-6c06-4956-8b86-aa096f060ac6
# API to work with an IIIF image service
function iiifsvc()
	IIIFservice("http://www.homermultitext.org/iipsrv",
	"/project/homer/pyramidal/deepzoom")
end

# ╔═╡ 71d7a180-5742-415c-9013-d3d1c0ca920c

# Compose markdown for thumbnail images linked to ICT with overlay of all
# DSE regions.
function completenessView(urn, repo)
     
	# Group images with ROI into a dictionary keyed by image
	# WITHOUT RoI.
	grouped = Dict()
	for row in eachrow(surfaceDse(repo, urn))
		trimmed = CitableObject.dropsubref(row.image)
		if haskey(grouped, trimmed)
			push!(grouped[trimmed], row.image)
		else
			grouped[trimmed] = [row.image]
		end
	end

	mdstrings = []
	for k in keys(grouped)
		thumb = markdownImage(k, iiifsvc(), thumbht)
		params = map(img -> "urn=" * img.urn * "&", grouped[k]) 
		lnk = ict() * join(params,"") 
		push!(mdstrings, "[$(thumb)]($(lnk))")
		
	end
	join(mdstrings, " ")

end

# ╔═╡ 9e6f8bf9-4aa7-4253-ba3f-695b13ca6def
# Display link for completeness view
begin
	if isempty(surface)
		md""
	else
		Markdown.parse(completenessView(Cite2Urn(surface), editorsrepo()))
	end
end

# ╔═╡ 59fbd3de-ea0e-4b96-800c-d5d8a7272922
# Compose markdown for one row of display interleaving citable
# text passage and indexed image.
function accuracyView(row::DataFrameRow)
	catalog = textcatalog_df(editorsrepo())
    title 	= worktitle(catalog, row.passage)
	citation = string("*", title, "*, **" * passagecomponent(row.passage)  * "** ")
	tidy = EditorsRepo.baseurn(row.passage)
	
	txt = diplomatic_passagetext(editorsrepo(), tidy)
	caption = passagecomponent(tidy)
	
	img = linkedMarkdownImage(ict(), row.image, iiifsvc(); ht=w, caption=caption)
	
	#urn
	record = """$(citation) $(txt)

$(img)

---
"""
	record
end

# ╔═╡ 73839e47-8199-4755-8d55-362185907c45
# Display for visual validation of DSE indexing
begin

	if surface == ""
		md""
	else
		surfDse = surfaceDse(editorsrepo(), Cite2Urn(surface) )
		cellout = []
		
		try
			for r in eachrow(surfDse)
				push!(cellout, accuracyView(r))
			end

		catch e
			html"<p class='danger'>Problem with XML edition: see message below</p>"
		end
		Markdown.parse(join(cellout,"\n"))				
		
	end

end

# ╔═╡ 6826f84a-542a-4de6-b862-79bc604ef559
md"> Substitute Pkg.TOML reader"

# ╔═╡ 70384afe-4853-4ce1-9d02-74946e396b97
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

# ╔═╡ a4d4970f-5f26-49de-85d0-44352ef0f2e4
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
CSV = "~0.9.10"
CitableCorpus = "~0.7.3"
CitableImage = "~0.2.3"
CitableObject = "~0.8.4"
CitablePhysicalText = "~0.3.3"
CitableTeiReaders = "~0.7.2"
CitableText = "~0.11.2"
DataFrames = "~1.2.2"
EditionBuilders = "~0.6.1"
EditorsRepo = "~0.14.4"
HTTP = "~0.9.16"
ManuscriptOrthography = "~0.2.2"
Orthography = "~0.15.0"
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
git-tree-sha1 = "74147e877531d7c172f70b492995bc2b5ca3a843"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.10"

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
git-tree-sha1 = "f0615acff31e5aa57d6842c48d816e77537c5c9e"
uuid = "d6f014bd-995c-41bd-9893-703339864534"
version = "4.0.0"

[[CitableCorpus]]
deps = ["CitableBase", "CitableText", "CiteEXchange", "DataFrames", "DocStringExtensions", "Documenter", "HTTP", "Test"]
git-tree-sha1 = "8f71ee5e831c8517ee8338540f6c9bfa73466b89"
uuid = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
version = "0.7.3"

[[CitableImage]]
deps = ["CitableBase", "CitableObject", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "fb7944e013ae43406d0a141dec723cfa2a13a533"
uuid = "17ccb2e5-db19-44b3-b354-4fd16d92c74e"
version = "0.2.3"

[[CitableObject]]
deps = ["CitableBase", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "b3c5e5229b3197c5bd9124ae099d38f58652bca5"
uuid = "e2b2f5ea-1cd8-4ce8-9b2b-05dad64c2a57"
version = "0.8.4"

[[CitableParserBuilder]]
deps = ["CSV", "CitableBase", "CitableCorpus", "CitableObject", "CitableText", "DataStructures", "DocStringExtensions", "Documenter", "HTTP", "Orthography", "Test", "TypedTables"]
git-tree-sha1 = "ccfc55e0d8116c6cbba1ce137cae4ec95178b299"
uuid = "c834cb9d-35b9-419a-8ff8-ecaeea9e2a2a"
version = "0.20.2"

[[CitablePhysicalText]]
deps = ["CSV", "CitableObject", "CitableText", "CiteEXchange", "DataFrames", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "74e0be40e4a855335ee2e525a1443d2b1df70fb0"
uuid = "e38a874e-a7c2-4ff3-8dea-81ae2e5c9b07"
version = "0.3.3"

[[CitableTeiReaders]]
deps = ["CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "EzXML", "Test"]
git-tree-sha1 = "e45b57aa98382cdb5268541d2755b5b4cb1ec11d"
uuid = "b4325aa9-906c-402e-9c3f-19ab8a88308e"
version = "0.7.2"

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
git-tree-sha1 = "d6a8bf51be16b58ea3456ba47acb0b4397de984c"
uuid = "2fb66cca-c1f8-4a32-85dd-1a01a9e8cd8f"
version = "0.6.1"

[[EditorsRepo]]
deps = ["AtticGreek", "CSV", "CitableBase", "CitableCorpus", "CitableObject", "CitablePhysicalText", "CitableTeiReaders", "CitableText", "CiteEXchange", "DataFrames", "DocStringExtensions", "Documenter", "EditionBuilders", "Lycian", "ManuscriptOrthography", "Orthography", "PolytonicGreek", "Test"]
git-tree-sha1 = "097b3c22a68f721b62575443f1ec7f76a3cde8be"
uuid = "3fa2051c-bcb6-4d65-8a68-41ff86d56437"
version = "0.14.4"

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
git-tree-sha1 = "481f84e22e3db665f6ae98ce165024fc0ceab2c1"
uuid = "7c215dd3-d1b4-4517-b6c6-0123f1059a20"
version = "0.5.2"

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
deps = ["CitableBase", "CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "OrderedCollections", "StatsBase", "Test", "TypedTables", "Unicode"]
git-tree-sha1 = "3cd7d46f0bae8dc2915f63d6a68073e65477824b"
uuid = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
version = "0.15.0"

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
# ╠═d2ff2f48-70ea-4837-a29d-1884eacebd61
# ╠═2bcf30fd-8c7b-4434-9fdf-2f611272f1f8
# ╟─15050388-e00b-408f-aca2-1e3a42051d6d
# ╠═e099bf98-fbe3-4ad1-965a-3b94ca01d0e4
# ╟─03dc3687-0e1a-4796-912d-3d8faf23f3c7
# ╟─35255eb9-1f54-4f9d-8c58-2d450e09dff9
# ╟─617ce64a-d7b1-4f66-8bd0-f7a240a929a7
# ╠═8d407e7a-1201-4dd3-bddd-368362037205
# ╟─ee2f04c1-42bb-46bb-a381-b12138e550ee
# ╟─834a67df-8c8b-47c6-aa3e-20297576019a
# ╟─8fcf792e-71eb-48d9-b0e6-e7e175628ccd
# ╟─9e6f8bf9-4aa7-4253-ba3f-695b13ca6def
# ╟─06bfa57d-2bbb-498e-b68e-2892d7186245
# ╟─ad541819-7d4f-4812-8476-8a307c5c1f87
# ╟─73839e47-8199-4755-8d55-362185907c45
# ╟─3dd88640-e31f-4400-9c34-2adc2cd4c532
# ╟─3b04a423-6d0e-4221-8540-ad457d0bb65e
# ╟─ea1b6e21-7625-4f8f-a345-8e96449c0757
# ╟─fd401bd7-38e5-44b5-8131-dbe5eb4fe41b
# ╟─066b9181-9d41-4013-81b2-bcc37878ab68
# ╟─5cba9a9c-74cc-4363-a1ff-026b7b3999ea
# ╟─71d7a180-5742-415c-9013-d3d1c0ca920c
# ╟─59fbd3de-ea0e-4b96-800c-d5d8a7272922
# ╟─3cb683e2-5350-4262-b693-0cddee340254
# ╟─1814e3b1-8711-4afd-9987-a41d85fd56d9
# ╟─3dd9b96b-8bca-4d5d-98dc-a54e00c75030
# ╟─ec0f3c61-cf3b-4e4c-8419-176626a0888c
# ╟─43734e4f-2efc-4f12-81ac-bce7bf7ada0a
# ╟─080b744e-8f14-406d-bdd2-fbcd3c1ec753
# ╟─806b3733-6c06-4956-8b86-aa096f060ac6
# ╟─6826f84a-542a-4de6-b862-79bc604ef559
# ╟─a4d4970f-5f26-49de-85d0-44352ef0f2e4
# ╟─70384afe-4853-4ce1-9d02-74946e396b97
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
