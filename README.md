# RogerSassc

[Sass](http://sass-lang.com/) compilation based on [sassc-ruby](https://github.com/bolandrm/sassc-ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'roger_sassc'
```

And then execute:

    $ bundle

## Usage

Add the following lines to your Mockupfile

### Middleware
```
mockup.serve do |s|
    s.use(RogerSassc::Middleware)
end
```

Several options can be supplied, as can be seen in [middleware.rb](https://github.com/DigitPaint/roger_sassc/blob/master/lib/roger_sassc/middleware.rb#L17-L19)

### Release
```
mockup.release do |r|
    r.use(:sassc)
end
```

Several options can be supplied, as can be seen in [processor.rb](https://github.com/DigitPaint/roger_sassc/blob/master/lib/roger_sassc/processor.rb#L11-L15)

### Load path
When working with files that are hard to reach with a relative path,
load_paths can help out to ensure cleanness of otherwise long paths.

```
# Mockupfile

RogerSassc.append_path "plugins"
```

Example:
```
// Without append_path
import '../../../../plugins/my-awesome-plugin/main';

// Say we add global to the load_path as done above
import 'my-awesome-plugin/main';
```

## Notes

The wrapper around libsass does not support ruby < 2.0.0.

## Contributing

1. [Fork it](https://github.com/digitpaint/roger_sassc/fork)
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Run the tests (`rake`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request
