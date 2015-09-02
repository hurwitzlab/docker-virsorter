#!/usr/bin/env perl
use strict;
# Script to generate the merged contig annotation (annotate each gene)
# Argument 0 : MGA predict file
# Argument 1 : HMMsearch vs Phage Clusters
# Argument 2 : BLast vs unclustered
# Argument 3 : HMMsearch vs PFAMa
# Argument 4 : HMMsearch vs PFAMb
# Argument 5 : Ref Phage Clusters
# Argument 6 : Out file
if (($ARGV[0] eq "-h") || ($ARGV[0] eq "--h") || ($ARGV[0] eq "-help" )|| ($ARGV[0] eq "--help") || (!defined($ARGV[6])))
{
	print "# Script to generate the merged contig annotation (annotate each gene)
# Argument 0 : MGA predict file
# Argument 1 : HMMsearch vs Phage Clusters
# Argument 2 : BLast vs unclustered
# Argument 3 : HMMsearch vs PFAMa
# Argument 4 : HMMsearch vs PFAMb
# Argument 5 : Ref Phage Clusters
# Argument 6 : Out file\n";
	die "\n";
}


my $mga_file=$ARGV[0];
my $hmm_phage_clusters=$ARGV[1];
my $blast_vs_unclustered=$ARGV[2];
my $hmm_pfama=$ARGV[3];
my $hmm_pfamb=$ARGV[4];
my $ref_phage_clusters=$ARGV[5];
my $out_file=$ARGV[6];


my $circu_file=$mga_file;
$circu_file=~s/_mga_final.predict/_circu.list/;
my %circu;
open(CI,"<$circu_file") || die "pblm ouverture fichier $circu_file\n";
while(<CI>){
	chomp($_);
	my @tab=split("\t",$_);
	my $id_c=$tab[0];
	$circu{$id_c}=1;
}
close CI;

my $n2=0;
my %size;
my %order_gene;
my %predict;
my %type;
my $id_c="";
my @liste_contigs;
open(MGA,"<$mga_file") || die ("pblm opening file $mga_file");
while(<MGA>){
	chomp($_);
	if ($_=~/^>(.*)/){
		my @tab=split("\t",$1);
		$id_c=$tab[0];
		$size{$id_c}=$tab[1];
		$n2=0;
		push(@liste_contigs,$id_c);
	}
	else{
		my @tab=split("\t",$_);
		$predict{$id_c}{$tab[0]}=$_;
		$order_gene{$id_c}{$tab[0]}=$n2;
		$n2++;
	}
}
close MGA;

# first the BLAST vs unclustered , which will eventually be erased by the HMM vs Phage cluster (that we trust more)
my %affi_phage_cluster;
my $score_blast_th=50;
my $evalue_blast_th=0.001;
open(BL,"<$blast_vs_unclustered") || die ("pblm opening file $blast_vs_unclustered");
while (<BL>){
	chomp($_);
	my @tab=split("\t",$_);
	my $seq=$tab[0];
	my $match=$tab[1];
	$match=~s/\|/_/g;
	my $evalue=$tab[10];
	my $score=$tab[11];
	if ($score>=$score_blast_th && $evalue<=$evalue_blast_th && (!defined($affi_phage_cluster{$seq}) || ($score>$affi_phage_cluster{$seq}{"score"})) && ($seq ne $match)){ ## We add the $seq ne $match so that we do not count a match to a phage sequence when it's only itself in the unclustered pool from a previous revision.
		$affi_phage_cluster{$seq}{"score"}=$score;
		$affi_phage_cluster{$seq}{"evalue"}=$evalue;
		$affi_phage_cluster{$seq}{"match"}=$match;
# 				print "$seq match $match\n";
	}
	
}
close BL;


my $score_th=40;
my $evalue_th=0.00001;

open(TB,"<$hmm_phage_clusters") || die "pblm opening file $hmm_phage_clusters\n";
while(<TB>){
	chomp($_);
	if ($_=~m/^#/){
		next;
	}
	else{
		my @splign=split(m/\s+/,$_);
		my $seq=$splign[0];
		my $match=$splign[2];
		$match=~s/\.ali_faa//g;
		my $evalue=$splign[4];
		my $score=$splign[5];
		if ($score>=$score_th && $evalue<=$evalue_th && (!defined($affi_phage_cluster{$seq}) || ($score>$affi_phage_cluster{$seq}{"score"}))){
			$affi_phage_cluster{$seq}{"score"}=$score;
			$affi_phage_cluster{$seq}{"evalue"}=$evalue;
			$affi_phage_cluster{$seq}{"match"}=$match;
# 				print "$seq match $match\n";
		}
	}
}
close TB;

my %affi_pfam;
open(TB,"<$hmm_pfama") || die "pblm opening file $hmm_pfama\n";
while(<TB>){
	chomp($_);
	if ($_=~m/^#/){
		next;
	}
	else{
		my @splign=split(m/\s+/,$_);
		my $seq=$splign[0];
		my $match=$splign[2];
		my $evalue=$splign[4];
		my $score=$splign[5];
		if ($score>=$score_th && $evalue<=$evalue_th && (!defined($affi_pfam{$seq}) || ($score>$affi_pfam{$seq}{"score"}))){
			$affi_pfam{$seq}{"score"}=$score;
			$affi_pfam{$seq}{"evalue"}=$evalue;
			$affi_pfam{$seq}{"match"}=$match;
		}
	}
}
close TB;


open(TB,"<$hmm_pfamb") || die "pblm opening file $hmm_pfamb\n";
while(<TB>){
	chomp($_);
	if ($_=~m/^#/){
		next;
	}
	else{
		my @splign=split(m/\s+/,$_);
		my $seq=$splign[0];
		my $match=$splign[2];
		my $evalue=$splign[4];
		my $score=$splign[5];
		if ($score>=$score_th && $evalue<=$evalue_th && (!defined($affi_pfam{$seq}) || ($score>$affi_pfam{$seq}{"score"}))){
			$affi_pfam{$seq}{"score"}=$score;
			$affi_pfam{$seq}{"evalue"}=$evalue;
			$affi_pfam{$seq}{"match"}=$match;
		}
	}
}
close TB;


my %phage_cluster;
open(REF,"<$ref_phage_clusters") || die ("pblm opening file $ref_phage_clusters\n");
while (<REF>){
	chomp($_);
	my @tab=split(/\|/,$_);
	$phage_cluster{$tab[0]}{"category"}=$tab[1];
}
close REF;


# Final output
# >Contig,nb_genes,circularity
# gene_id,start,stop,length,strand,affi_phage,score,evalue,category,affi_pfam,score,evalue,
open(S1,">$out_file") || die ("pblm opening file $out_file\n");
my $n=0;
foreach(@liste_contigs){
	$n++;
	if ($n % 10000 == 0){print "$n-ieme contig\n";}
	my $contig_c=$_;
	my $circ="l";
	if ($circu{$contig_c}==1){$circ="c";}
	my @tab_genes=sort {$order_gene{$contig_c}{$a} <=> $order_gene{$contig_c}{$b} } keys %{$predict{$contig_c}};
	my $n_g=$#tab_genes+1;
	print S1 ">$contig_c|$n_g|$circ\n";
	foreach(@tab_genes){
		my $g_c=$_;
		my @tab=split("\t",$predict{$contig_c}{$g_c});
		$g_c=$contig_c."-".$g_c;
		my $name=$tab[0];
		my $start=$tab[1];
		my $stop=$tab[2];
		my $strand=$tab[3];
		my $frame=$tab[4];
		my $affi_pc="-";
		my $affi_pc_score="-";
		my $affi_pc_evalue="-";
		my $affi_category="-";
		if (defined($affi_phage_cluster{$g_c})){
			my $phage_c=$affi_phage_cluster{$g_c}{"match"};
			if (defined($phage_cluster{$phage_c}{"category"})){$affi_category=$phage_cluster{$phage_c}{"category"};}
# 			else{print "No category for $phage_c ????????\n";} # Blast unclustered do not have any category
			$affi_pc=$phage_c;
			$affi_pc_score=$affi_phage_cluster{$g_c}{"score"};
			$affi_pc_evalue=$affi_phage_cluster{$g_c}{"evalue"};
		}
		my $affi_pfam="-";
		my $affi_pfam_score="-";
		my $affi_pfam_evalue="-";
		if (defined($affi_pfam{$g_c})){
			$affi_pfam=$affi_pfam{$g_c}{"match"};
			$affi_pfam_score=$affi_pfam{$g_c}{"score"};
			$affi_pfam_evalue=$affi_pfam{$g_c}{"evalue"};
		}
		my $length=$stop-$start;
		if ($length<0){ # It can happen if one gene overlap the contig origin
			$length=($size{$contig_c}-$start)+$stop;
		}
		print S1 "$g_c|$start|$stop|$length|$strand|$affi_pc|$affi_pc_score|$affi_pc_evalue|$affi_category|$affi_pfam|$affi_pfam_score|$affi_pfam_evalue\n";
	}
}

close S1;







