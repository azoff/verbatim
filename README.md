Verbatim Static Front-End
===========================
The web interface for Verbatim

<!-- TODO
[![Build Status](https://travis-ci.org/azoff/mintpool-website.png?branch=master)](https://travis-ci.org/azoff/mintpool-website)
-->

Getting Started
---------------
To install the front-end, you'll need [jekyll][2], a popular static site generator. Jekyll is a [ruby][5] app so, to
[install it][3], you'll need [rubygems][4]. Most modern 'nix distros and OSX come with ruby pre-installed. Assuming you
now have ruby, installing jekyll is pretty straightforward from a bash terminal:

```bash
$> sudo gem install jekyll
```

Once installed, you can run the static site by running `jekyll serve` from the project root. If developing, enable the
`--watch` flag for real-time updates:

```bash
$> jekyll serve --watch
```

The site should now be running on `http://localhost:4000`. If you're working with any CSS, you'll also need [compass][6]
and [sass][6]. The install is just as straightforward as installing jekyll:

```bash
$> sudo gem install sass compass
```

You can now compile all the `scss` files into `css` by running `compass compile` from the project root. Just like with
jekyll, you can also have compass watch for changes during active development:

```bash
$> compass watch
```

That's it, You can now develop against the static site. If you want to learn more about these technologies, check out
the references section.

References
----------
- [Jekyll Documentation][8]
- [SASS Documentation][9]
- [Compass Documentation][10]

[1]:http://mintpool.us
[2]:http://jekyllrb.com/
[3]:http://jekyllrb.com/docs/installation/
[4]:http://rubygems.org/
[5]:https://www.ruby-lang.org/en/
[6]:http://compass-style.org/
[7]:http://sass-lang.com/
[8]:http://jekyllrb.com/docs/home/
[9]:http://sass-lang.com/documentation/file.SASS_REFERENCE.html
[10]:http://compass-style.org/reference/compass/
