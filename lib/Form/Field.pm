module Form::Field;

use Form::TextFormatting;

# RAKUDO: only here until we can export them from Form::TextFormatting
#enum Justify <left right centre full>;
#enum Alignment <top middle bottom>;

role Field {
	has Bool $.block is rw;
	has Int $.width is rw;
	has $.alignment is rw;
	has $.data is rw;
	
	method format($data) { ... }
	method align(@lines, $height) {
		if @lines.elems < $height {
			my @extra = (' ' x $.width) xx ($height - @lines.elems);
			if $.alignment == Alignment::top {
				return (@lines, @extra);
			}
			elsif $.alignment == Alignment::bottom {
				return (@extra, @lines);
			}
			else {
				my @top = (' ' x $.width) xx (int(@extra.elems / 2));
				my @bottom = @top;
				@extra.elems % 2 and @bottom.push(' ' x $.width);
				return (@top, @lines, @bottom);
			}
		}
		elsif @lines.elems > $height {
			# TODO: we may need to be cleverer about which alignments
			return @lines[^$height];
		}
		else {
			return @lines;
		}
	}
}


# RAKUDO: Don't know what's correct here, but until [perl #63510] is resolved,
#         we need to write "Form::Field::Field", not "Field".
class TextField does Form::Field::Field {
	has $.justify is rw;

	method format($data) {
		my @lines = Form::TextFormatting::unjustified-wrap(~$data, $.width);

		$.block or @lines = @lines[^1];

		my Callable $justify-function;
		if $.justify == Justify::left {
			$justify-function = &Form::TextFormatting::left-justify;
		}
		elsif $.justify == Justify::right {
			$justify-function = &Form::TextFormatting::right-justify;
		}
		elsif $.justify == Justify::centre {
			$justify-function = &Form::TextFormatting::centre-justify;
		}
		else {
			$justify-function = &Form::TextFormatting::full-justify;
		}
		# RAKUDOBUG: .=map: { } doesn't seem to parse, but .map: { } does
		@lines.=map({ $justify-function($_, $.width, ' ') });

		return @lines;
	}
}

# RAKUDO: Don't know what's correct here, but until [perl #63510] is resolved,
#         we need to write "Form::Field::Field", not "Field".
class VerbatimField does Form::Field::Field {
	method format($data) { return [$.data]; }
}


# vim: ft=perl6 sw=4 ts=4 noexpandtab
