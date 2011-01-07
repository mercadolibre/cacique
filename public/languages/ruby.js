/*
 * CodePress regular expressions for Ruby syntax highlighting
 */

// Ruby
Language.syntax = [
	{ input : /\"(.*?)(\"|<br>|<\/P>)/g, output : '<s style="text-decoration: none;">"$1$2</s>' }, // strings double quote 
	{ input : /\'(.*?)(\'|<br>|<\/P>)/g, output : '<s style="text-decoration: none;">\'$1$2</s>' }, // strings single quote
	{ input : /([\$\@\%]+)([\w\.]*)/g, output : '<a>$1$2</a>' }, // vars
	{ input : /(def\s+)([\w\.]*)/g, output : '$1<em>$2</em>' }, // functions
	{ input : /\b(alias|and|BEGIN|begin|break|case|class|def|defined|do|else|elsif|END|end|ensure|false|for|if|in|module|next|nil|not|or|redo|rescue|retry|return|self|super|then|true|undef|unless|until|when|while|yield)\b/g, output : '<b>$1</b>' }, // reserved words
	{ input  : /([\(\){}])/g, output : '<u>$1</u>' }, // special chars
	{ input  : /#(.*?)(<br>|<\/P>)/g, output : '<i>#$1</i>$2' } // comments
];

Language.snippets = [
	{ input : 'if', output : 'if $0\n\t\nelse\n\t\nend' },
	{ input : 'while', output : 'while $0\n\t\nend' },
  { input : 'do', output : 'do $0\n\t\nend' },
  { input : 'require', output : 'require("$0")' },
  { input : 'def', output : 'def $0\n\t\nend' },
  { input : 'print', output : 'print \"$0\"' },
  { input : 'puts', output : 'puts \"$0\"' }, 
	{ input : 'case', output : 'case $0\n\twhen "": \n\twhen "": \n\telse \nend' },
	{ input : 'begin', output : 'begin $0\n\t\nrescue\n\t\nend' },	
  { input : 'each', output : 'each do |var|\n\t\$0 \nend' },	
  { input : 'data', output : 'data[:$0]' },   

//Selenium
{ input : 'sele', output : 'selenium.' },
{ input : 'selen', output : 'selenium' },
]

Language.complete = [
	{ input : '(', output : '\($0\)' },
	{ input : '[', output : '\[$0\]' },
	{ input : '{', output : '{$0}' }		
]

Language.shortcuts = [
	{ input : '[space]', output : '&nbsp;' },
	{ input : '[enter]', output : '<br />' } ,
	{ input : '[j]', output : 'testing' },
	{ input : '[7]', output : '&amp;' },
]

