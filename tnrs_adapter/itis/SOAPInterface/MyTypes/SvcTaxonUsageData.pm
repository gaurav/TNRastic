package MyTypes::SvcTaxonUsageData;
use strict;
use warnings;


__PACKAGE__->_set_element_form_qualified(1);

sub get_xmlns { 'http://data.itis_service.itis.usgs.org/xsd' };

our $XML_ATTRIBUTE_CLASS;
undef $XML_ATTRIBUTE_CLASS;

sub __get_attr_class {
    return $XML_ATTRIBUTE_CLASS;
}


use base qw(MyTypes::SvcTaxonomicBase);
# Variety: sequence
use Class::Std::Fast::Storable constructor => 'none';
use base qw(SOAP::WSDL::XSD::Typelib::ComplexType);

Class::Std::initialize();

{ # BLOCK to scope variables

my %tsn_of :ATTR(:get<tsn>);
my %taxonUsageRating_of :ATTR(:get<taxonUsageRating>);

__PACKAGE__->_factory(
    [ qw(        tsn
        taxonUsageRating

    ) ],
    {
        'tsn' => \%tsn_of,
        'taxonUsageRating' => \%taxonUsageRating_of,
    },
    {
        'tsn' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
        'taxonUsageRating' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
    },
    {

        'tsn' => 'tsn',
        'taxonUsageRating' => 'taxonUsageRating',
    }
);

} # end BLOCK







1;


=pod

=head1 NAME

MyTypes::SvcTaxonUsageData

=head1 DESCRIPTION

Perl data type class for the XML Schema defined complexType
SvcTaxonUsageData from the namespace http://data.itis_service.itis.usgs.org/xsd.






=head2 PROPERTIES

The following properties may be accessed using get_PROPERTY / set_PROPERTY
methods:

=over

=item * taxonUsageRating




=back


=head1 METHODS

=head2 new

Constructor. The following data structure may be passed to new():

 { # MyTypes::SvcTaxonUsageData
   taxonUsageRating =>  $some_value, # string
 },




=head1 AUTHOR

Generated by SOAP::WSDL

=cut

