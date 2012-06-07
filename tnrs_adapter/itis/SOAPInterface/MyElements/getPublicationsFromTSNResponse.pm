
package MyElements::getPublicationsFromTSNResponse;
use strict;
use warnings;

{ # BLOCK to scope variables

sub get_xmlns { 'http://itis_service.itis.usgs.org' }

__PACKAGE__->__set_name('getPublicationsFromTSNResponse');
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
        'return' => 'MyTypes::SvcTaxonPublicationList',
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

MyElements::getPublicationsFromTSNResponse

=head1 DESCRIPTION

Perl data type class for the XML Schema defined element
getPublicationsFromTSNResponse from the namespace http://itis_service.itis.usgs.org.







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

 my $element = MyElements::getPublicationsFromTSNResponse->new($data);

Constructor. The following data structure may be passed to new():

 {
   return =>  { # MyTypes::SvcTaxonPublicationList
     publications =>  { # MyTypes::SvcTaxonPublication
       actualPubDate =>  $some_value, # string
       isbn =>  $some_value, # string
       issn =>  $some_value, # string
       listedPubDate =>  $some_value, # string
       pages =>  $some_value, # string
       pubComment =>  $some_value, # string
       pubName =>  $some_value, # string
       pubPlace =>  $some_value, # string
       publisher =>  $some_value, # string
       referenceAuthor =>  $some_value, # string
       referenceFor =>  { # MyTypes::SvcReferenceForElement
         name =>  $some_value, # string
         refLanguage =>  $some_value, # string
         referredTsn =>  $some_value, # string
       },
       title =>  $some_value, # string
       updateDate =>  $some_value, # string
     },
   },
 },

=head1 AUTHOR

Generated by SOAP::WSDL

=cut
