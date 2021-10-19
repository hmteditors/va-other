using CitableParserBuilder
using CitableText
using CitableCorpus
using Orthography
using PolytonicGreek
using Kanones, Kanones.FstBuilder

# Assume that this directory is checked out next door.  Adjust if necessary
function kroot()
    joinpath((pwd() |> dirname |> dirname), "Kanones.jl")
end


function customparser(rootdir)
    fstsrc  =  joinpath(rootdir, "fst")
    coreinfl = joinpath(rootdir, "datasets", "core-infl")
    corevocab = joinpath(rootdir, "datasets", "core-vocab")
    lysias = joinpath(rootdir, "datasets", "lysias")
    lysiasnouns = joinpath(rootdir,  "datasets","lysias-nouns")
    va = joinpath(pwd(), "datasets", "va-other")

    datasets = [corevocab, coreinfl, lysias, lysiasnouns, va]
    kd = Kanones.Dataset(datasets)
    tgt = joinpath(rootdir,  "parsers", "lysiasparser")
    buildparser(kd,fstsrc, tgt; force = true)
end

# 1. load a corpus 
psgs = []
for u in citation_df(editorsrepo())[:,:urn]
    push!(psgs, EditorsRepo.normalized_passages(repo, u))
end
c = psgs |> Iterators.flatten |> collect |> CitableTextCorpus

# 2. tokenize 
ortho = literaryGreek()
tknized = tokenizedcorpus(c,ortho)

# 3. parse and write to disk
function reparse(tkncorpus, parser)
    parsed = parsecorpus(tkncorpus, parser)
    open(joinpath(pwd(), "morphology", "va-other-parses.cex"),"w") do io
        write(io, delimited(parsed))
    end
end

# Execute this repeatedly as you edit/revise:
function rebuild()
    p = customparser(kroot())
    reparse(tknized, p)
end





# For labelling lemmata:
lsj = Kanones.lsjdict(joinpath(kroot(), "lsj", "lsj-lemmata.cex"))