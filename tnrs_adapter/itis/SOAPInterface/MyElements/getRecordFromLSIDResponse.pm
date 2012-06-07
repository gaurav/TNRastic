
package MyElements::getRecordFromLSIDResponse;
use strict;
use warnings;

{ # BLOCK to scope variables

sub get_xmlns { 'http://itis_service.itis.usgs.org' }

__PACKAGE__->__set_name('getRecordFromLSIDResponse');
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

my %return_of :ATTR(:get<return>);

__PACKAGE__->_factory(
    [ qw(        return

    ) ],
    {
        'return' => \%return_of,
    },
    {
        'return' => 'MyTypes::SvcLSIDRecord',
    },
    {

        'return' => 'return',
    }
);

} # end BLOCK






} # end of BLOCK



1;


=pod

=head1 NAME

MyElements::getRecordFromLSIDResponse

=head1 DESCRIPTION

Perl data type class for the XML Schema defined element
getRecordFromLSIDResponse from the namespace http://itis_service.itis.usgs.org.







=head1 PROPERTIES

The following properties may be accessed using get_PROPERTY / set_PROPERTY
methods:

=over

=item * return

 $element->set_return($data);
 $element->get_return();





=back


=head1 METHODS

=head2 new

 my $element = MyElements::getRecordFromLSIDResponse->new($data);

Constructor. The following data structure may be passed to new():

 {
   return =>  { # MyTypes::SvcLSIDRecord
     authorship =>  $some_value, # string
     genusPart =>  $some_value, # string
     infragenericEpithet =>  $some_value, # string
     infraspecificEpithet =>  $some_value, # string
     lsid =>  $some_value, # string
     lsidText =>  $some_value, # string
     nameComplete =>  $some_value, # string
     nomenclaturalCode =>  $some_value, # string
     rank =>  $some_value, # string
     rankString =>  $some_value, # string
     specificEpithet =>  $some_value, # string
     uninomial =>  $some_value, # string
   },
 },

=head1 AUTHOR

Generated by SOAP::WSDL

=cut
