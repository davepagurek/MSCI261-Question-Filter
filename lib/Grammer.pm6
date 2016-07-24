unit module Grammer;

constant $nouns is export = "data/conv.data.noun".IO.slurp;
#constant $adjectives is export = "data/conv.data.adj".IO.slurp;
constant $verbs is export = "data/conv.data.verb.broken".IO.slurp;
constant $adv is export = "data/conv.data.adv".IO.slurp;
constant $prepositions is export = "data/conv.data.prep".IO.slurp;
constant $articles is export = "data/conv.data.article".IO.slurp;
constant @names is export = "data/names".IO.slurp.split(/\W+/)[0..*-2];

use Grammar::Tracer;
grammar Grammar {
  token TOP { :i
    $<sentence>=<sentence>
  }

  regex sentence { :i
    $<subject>=<np> ' ' $<action>=<vp> [' ' $<prep>=<preposition> ' ' $<object>=<np>]?
  }

  token end { :i <[.;?!]> }

  regex np { :i
    $<a>=[[<article> | <possessive>] ' ']? $<adjective>=[<adjp> ' ']? $<n>=[<noun>+ % ' '] $<descriptor>=[' ' ['that'|'which'] ' ' <vp>]?
  }

  #regex adjp { :i
    #[<advp> ' ']? <adjective>
  #}

  regex adjp { :i
    <adj>+ % ' '
  }

  regex vp { :i
    $<adjectives>=[<adjp> ' ']? $<actions>=[<verb>+ % ' '] [' ' $<prep>=[<preposition> ' ']? $<object>=<np> ]?
  }


  token possessive { :i
    my | your | his | hers | their
  }

  token number { :i
    '$'? <[\d\,]>+ '%'?
  }

  #token noun { :i @nouns | I | me | you | this | that }
  #token adjective { :i <number> | <possessive>  }
  #token adverb { :i @adverbs }
  #token verb { :i @verbs | is | am | are }
  #token preposition { :i @prepositions }

  regex article { :i \w*ART\w*'|'[\w+]}
  regex noun { :i \w*N\w*'|'[\w+] | <name> | <number> }
  regex adj { :i \w*ADJ\w*'|'[\w+] | ['$'? \d+] }
  #regex adverb { :i ADV[\w+] }
  regex verb { :i \w*V\w*'|'[\w+] }
  regex preposition { :i \w*P\w*'|'[\w+] }
  regex name { @names }
}

class Actions {
  method TOP($/) {
    $/.make: $<sentence>.made.subst(/\w+'|'(\w+)/, -> $/ { $0 }, :g);
  }

  method sentence($/) {
    my $act = $<action>.clone.made;
    my $sub = $<subject>.clone;
    my $oldsub = $<subject>.clone;
    if $<action><object> && (1..10).pick < 5 {
      $sub = $<action><object>.clone;
      $act.=subst(~$<action><object>, ~$oldsub, :g);
    }
    $/.make: $sub.made ~ " " ~ $act ~
      ($<prep> ?? " " ~ $<prep>.made ~ " " ~ $<object>.made !! "")
      ~ [".", ";", "!", "?"].pick;
  }

  method np($/) {
    #$/.make: ~$/;
    my $r = (1..20).pick;
    if $<a> && $r < 3 {
      $/.make: $<a> ~ "thing";
    } elsif $r == 3 {
      $/.make: @names.pick;
    } elsif $r < 5 {
      $/.make: "the value from Figure {(1..100).pick}";
    } else {
      #$/.make: ~($<article> ?? $<article>.made !! "") ~ ($<adjective> ?? $<adjective>.made !! "") ~ $<noun>;
      $/.make: ~$/;
    }
  }

  method vp($/) {
    $/.make: ($<adjectives> ?? ~$<adjectives> !! "")
    ~ $<actions>
    ~ ($<object>
        ?? ((1..3).pick == 1 ?? "" !! " " ~ $<prep> ~ " " ~ $<object>.made)
        !! "");
  }

  method preposition($/) {
    $/.make: ~$/;
  }
}

sub bastardize(Str $input) returns Str is export {
  return $input.split(/<[.;?!]>\s*/).map( -> $s {
    say $s;
    next if $s eq "";
    my $typed = $s.split(" ").map(-> $w {
      my $word = $w.lc.subst(/(<[$%]>)/, -> $/ { "\\"~$0 }, :g);
      my $re = /^^ <$word> $$/;
      my $prefixes = "";
      if $nouns ~~ $re {
        $prefixes = $prefixes ~ "N";
      }
      if $verbs ~~ $re {
        $prefixes = $prefixes ~ "V";
      }
      if $adv ~~ $re {
        $prefixes = $prefixes ~ "ADJ";
      #} elsif $adverbs ~~ $re {
        #"ADV$word";
      }
      if $prepositions ~~ $re {
        $prefixes = $prefixes ~ "P";
      }
      if $articles ~~ $re {
        $prefixes = $prefixes ~ "ART";
      }

      if $prefixes ne "" {
        "$prefixes|$w";
      } else {
        $w;
      }
    }).join(" ");
    say $typed;
    my $actions = Actions.new;
    my $match = Grammar.parse($typed, actions => $actions);
    say $match;
    $match.made.say if $match;
    $match.?made || ""
  }).join(" ");
}
