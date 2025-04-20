#############################################################################
#   Description:
#       Remove non-autosomal info from yeast cDNA fasta file
#
#   History: 
#   Date        Name        Modification
#   2019-10-05  Jason Bacon Begin
#############################################################################

BEGIN {
    FS=":";
}
{
    # Remove all features in the mitochondria chromosome
    # The fields are separated by ':' and the 3rd is the chromosome name,
    # which is "Mito" for mitochondria
    # >YPL071C_mRNA cdna chromosome:R64-1-1:XVI:420048:420518:...
    while ( ($0 ~ "^>") && ($3 == "Mito") )
    {
	# Remove all sequence data until the next feature
	do
	{
	    status=getline
	}   while ( (status == 1) && ($0 !~ "^>") );
    }
    print $0
}
