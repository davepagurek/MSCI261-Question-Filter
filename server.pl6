use lib "lib";
use Grammer;
use Web::App::Ballet;

use-http(3000);

my $main = "static/index.html".IO.slurp;
my $js = "static/index.js".IO.slurp;
my $css = "static/style.css".IO.slurp;

get '/bastardize' => -> $c {
  $c.content-type: 'text/plain';
  my $sentence = $c.get(:default("This is a test."), 'sentence');
  $c.send(bastardize($sentence));
}

get '/style.css' => -> $c {
  $c.content-type: 'text/css';
  $c.send($css);
}

get '/index.js' => -> $c {
  $c.content-type: 'text/javascript';
  $c.send($js);
}

get '/' => -> $c {
  $c.content-type: 'text/html';
  $c.send($main);
}

dance;
#say parse("Jimmy has a house. It depreciates at a rate of 2%. What is its value after 2 years?");
