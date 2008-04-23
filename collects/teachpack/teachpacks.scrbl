#lang scribble/doc

@(require scribble/manual
          (for-label scheme/base))

@title[#:style '(toc)]{Teachpacks}

Teaching languages are small subsets of a full programming language. While
 such restrictions simplify error diagnosis and the construction of tools,
 they also make it impossible (or at least difficult) to write some
 interesting programs. To circumvent this restriction, it is possible to
 import teachpacks into programs written in a teaching language.

In principle, a teachpack is just a library written in the full language,
 not the teaching subset. Like any other library, it may export values,
 functions, etc. In contrast to an ordinary library, however, a teachpack
 must enforce the contracts of the "lowest" teaching language into which it
 is imported and signal errors in a way with which students are familiar at
 that level. 

This chapter covers the teachpacks for ``How to Design Programs'' and ``How
 to Design Classes.'' 

@include-section["htdp/Docs/htdp.scrbl"]

@include-section["htdc/Docs/htdc.scrbl"]
