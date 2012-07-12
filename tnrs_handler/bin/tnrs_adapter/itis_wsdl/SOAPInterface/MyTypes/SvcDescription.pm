package MyTypes::SvcDescription;
use strict;
use warnings;


__PACKAGE__->_set_element_form_qualified(1);

sub get_xmlns { 'http://itis_service.itis.usgs.org/xsd' };

our $XML_ATTRIBUTE_CLASS;
undef $XML_ATTRIBUTE_CLASS;

sub __get_attr_class {
    return $XML_ATTRIBUTE_CLASS;
}

use Class::Std::Fast::Storable constructor => 'none';
use base qw(SOAP::WSDL::XSD::Typelib::ComplexType);

Class::Std::initialize();

{ # BLOCK to scope variables

my %description_of :ATTR(:get<description>);

__PACKAGE__->_factory(
    [ qw(        description

    ) ],
    {
        'description' => \%description_of,
    },
    {
        'description' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
    },
    {

        'description' => 'description',
    }
);

} # end BLOCK







1;


=pod

=head1 NAME

MyTypes::SvcDescription

=head1 DESCRIPTION

Perl data type class for the XML Schema defined complexType
SvcDescription from the namespace http://itis_service.itis.usgs.org/xsd.






=head2 PROPERTIES

The following properties may be accessed using get_PROPERTY / set_PROPERTY
methods:

=over

=item * description




=back


=head1 METHODS

=head2 new

Constructor. The following data structure may be passed to new():

 { # MyTypes::SvcDescription
   description =>  $some_value, # string
 },




=head1 AUTHOR

Generated by SOAP::WSDL

=cut
