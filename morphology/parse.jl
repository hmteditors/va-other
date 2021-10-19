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

# load a corpus, tokenize and parse
#f = joinpath(pwd(), "scratch", "lysias1.cex")
#c = read(f) |> corpus_fromcex
ortho = literaryGreek()
tknized = tokenizedcorpus(c,ortho)


# For labelling lemmata:
lsj = Kanones.lsjdict(joinpath(kroot(), "lsj", "lsj-lemmata.cex"))