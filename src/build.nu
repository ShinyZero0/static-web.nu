#!/usr/bin/env nu

def main [] {

	prepare
	let out = ("~/public_html/" | path expand)
	let navbar = (make-navbar)
	let head = (open ./head.html)
	let www = (get-www)
	for file in $www {
		ensure ($out | path join (result-path $file))
		[
			$head,
			$navbar,
			"<body>",
			(open $file | comrak -t html),
			"</body>",

		]
		| str join "\n"
		| save -f ($out | path join (result-path $file) )
	}
	fd -t f -e html -e css . www
	| lines
	| each { |f|
		cp $f $out
	}
	make-index
	| save -f --raw ($out | path join index.html)
}

def "result-path" [ file ] {
	$file
	| path parse
	| update extension html
	| path join
	| path split
	| skip
	| path join
}
def "get-result-list" [] {
	
	let www = (get-www)
	$www | each { |f| result-path $f }
}

def "get-pretty-title" [] {

	path parse
	| reject extension
	| path join
	| path split
	| str title-case
	| str join ": "
}
def "get-true-path" [] {
	
	let input = $in
	let addition = ""
	$"($addition)($input)"
}
def "make-index" [] {
	let head = (open ./head.html)
	mut html = [$head '<ul>' '<h1>~ShinyZero0</h1>']
	for file in (get-result-list) {
		$html = (
			$html | append (
$'<li>
	<a href="($file | get-true-path)">(
	$file | get-pretty-title
	)</a>
</li>'
			)
		)
	}

	$html | append "</ul>"

}
def "make-navbar" [] {
	prepare
	let files = (get-result-list)
	mut navbar = [ '<div id="navbar">']
	for file in $files {
		$navbar = (
			$navbar
			| append $'<a href="($file | get-true-path)">(
				$file | get-pretty-title
			)</a>'
		)
	}
	$navbar = ($navbar | append '</div>')
	$navbar | str join "\n"
}

def-env prepare [] {
	cd ($env.CURRENT_FILE | path dirname)
}

def "ensure" [file] {
	mkdir ($file | path expand | path dirname)
}
def "get-www" [] {

	prepare
	fd -t f -e md . www | lines
}
