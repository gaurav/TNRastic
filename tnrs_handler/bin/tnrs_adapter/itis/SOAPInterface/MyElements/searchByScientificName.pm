
package MyElements::searchByScientificName;
use strict;
use warnings;

{ # BLOCK to scope variables

sub get_xmlns { 'http://itis_service.itis.usgs.org' }

__PACKAGE__->__set_name('searchByScientificName');
__PACKAGE__->__set_nillable();
__PACKAGE__->__set_minOccurs();
__PACKAGE__->__set_maxOccurs();
__PACKAGE__->__set_ref();

use base qw(
    SOAP::WSDL::XSD::Typelib::Element
    SOAP::WSDL::XSD::Typelib::ComplexType
);

our $XML_ATTRIBUTE_CLASS;
undef $XML_ATTRIBUTE_CLASS;

sub __get_attr_class {
    return $XML_ATTRIBUTE_CLASS;
}

use Class::Std::Fast::Storable constructor => 'none';
use base qw(SOAP::WSDL::XSD::Typelib::ComplexType);

Class::Std::initialize();

{ # BLOCK to scope variables

my %srchKey_of :ATTR(:get<srchKey>);

__PACKAGE__->_factory(
    [ qw(        srchKey

    ) ],
    {
        'srchKey' => \%srchKey_of,
    },
    {
        'srchKey' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
    },
    {

        'srchKey' => 'srchKey',
    }
);

} # end BLOCK






} # end of BLOCK



1;


=pod

=head1 NAME

MyElements::searchByScientificName

=head1 DESCRIPTION

Perl data type class for the XML Schema defined element
searchByScientificName from the namespace http://itis_service.itis.usgs.org.







=head1 PROPERTIES

The following properties may be accessed using get_PROPERTY / set_PROPERTY
methods:

=over

=item * srchKey

 $element->set_srchKey($data);
 $element->get_srchKey();





=back


=head1 METHODS

=head2 new

 my $element = MyElements::searchByScientificName->new($data);

Constructor. The following data structure may be passed to new():

 {
   srchKey =>  $some_value, # string
 },

=head1 AUTHOR

Generated by SOAP::WSDL

=cut

