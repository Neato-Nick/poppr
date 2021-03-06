#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#
# This software was authored by Zhian N. Kamvar and Javier F. Tabima, graduate 
# students at Oregon State University; Jonah C. Brooks, undergraduate student at
# Oregon State University; and Dr. Nik Grünwald, an employee of USDA-ARS.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for educational, research and non-profit purposes, without fee, 
# and without a written agreement is hereby granted, provided that the statement
# above is incorporated into the material, giving appropriate attribution to the
# authors.
#
# Permission to incorporate this software into commercial products may be
# obtained by contacting USDA ARS and OREGON STATE UNIVERSITY Office for 
# Commercialization and Corporate Development.
#
# The software program and documentation are supplied "as is", without any
# accompanying services from the USDA or the University. USDA ARS or the 
# University do not warrant that the operation of the program will be 
# uninterrupted or error-free. The end-user understands that the program was 
# developed for research purposes and is advised not to rely exclusively on the 
# program for any reason.
#
# IN NO EVENT SHALL USDA ARS OR OREGON STATE UNIVERSITY BE LIABLE TO ANY PARTY 
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
# LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, 
# EVEN IF THE OREGON STATE UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF 
# SUCH DAMAGE. USDA ARS OR OREGON STATE UNIVERSITY SPECIFICALLY DISCLAIMS ANY 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE AND ANY STATUTORY 
# WARRANTY OF NON-INFRINGEMENT. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS"
# BASIS, AND USDA ARS AND OREGON STATE UNIVERSITY HAVE NO OBLIGATIONS TO PROVIDE
# MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#==============================================================================#
#' Calculate dissimilarity or Euclidean distance for genlight objects
#' 
#' This function calculates both dissimilarity and Euclidean distances for 
#' [genlight][genlight-class] or [snpclone][snpclone-class] objects. 
#' 
#' @param x a [genlight][genlight-class] or [snpclone][snpclone-class] object.
#'   
#' @param percent `logical`. Should the distance be represented from 0 to 
#'   1? Default set to `TRUE`. `FALSE` will return the distance 
#'   represented as integers from 1 to n where n is the number of loci.
#'   This option has no effect if `euclidean = TRUE`
#'   
#' @param mat `logical`. Return a matrix object. Default set to 
#'   `FALSE`, returning a dist object. `TRUE` returns a matrix object.
#'   
#' @param missing_match `logical`. Determines whether two samples differing
#'   by missing data in a location should be counted as matching at that 
#'   location. Default set to `TRUE`, which forces missing data to match 
#'   with anything. `FALSE` forces missing data to not match with any other
#'   information, **including other missing data**.
#'   
#' @param scale_missing A logical. If `TRUE`, comparisons with missing
#'   data is scaled up proportionally to the number of columns used by
#'   multiplying the value by `m / (m - x)` where m is the number of
#'   loci and x is the number of missing sites. This option matches the behavior
#'   of base R's [dist()] function. 
#'   Defaults to `FALSE`.
#'   
#' @param euclidean `logical`. if `TRUE`, the Euclidean distance will
#'   be calculated.
#'   
#' @param differences_only `logical`. When `differences_only = TRUE`,
#'   the output will reflect the number of different loci. The default setting,
#'   `differences_only = FALSE`, reflects the number of different alleles.
#'   Note: this has no effect on haploid organisms since 1 locus = 1 allele.
#'   This option is NOT recommended. 
#'   
#' @param threads The maximum number of parallel threads to be used within this 
#'   function. A value of 0 (default) will attempt to use as many threads as 
#'   there are available cores/CPUs. In most cases this is ideal. A value of 1 
#'   will force the function to run serially, which may increase stability on 
#'   some systems. Other values may be specified, but should be used with 
#'   caution.
#'   
#'   
#' @details The default distance calculated here is quite simple and goes by
#'   many names depending on its application. The most familiar name might be
#'   the Hamming distance, or the number of differences between two strings.
#'   
#'   As of poppr version 2.8.0, this function now also calculates Euclidean
#'   distance and is considerably faster and more memory-efficient than the 
#'   standard `dist()` function. 
#'   
#' @note This function is optimized for [genlight][genlight-class] and
#'   [snpclone][snpclone-class] objects. This does not mean that it is a
#'   catch-all optimization for SNP data. Three assumptions must be met for this
#'   function to work:
#'   
#'   1. SNPs are bi-allelic 
#'   2. Samples are haploid or diploid
#'   3. All samples have the same ploidy
#'   
#'   If the user supplies a [genind][genind-class] or
#'   [genclone][genclone-class] object, [prevosti.dist()] will be used for
#'   calculation.
#'   
#' @return A dist object containing pairwise distances between samples.
#'   
#' @author Zhian N. Kamvar, Jonah C. Brooks
#' 
#' @export
#' @md
#' @seealso [diss.dist()], [snpclone][snpclone-class],
#'   [genlight][genlight-class], [win.ia()],  [samp.ia()]
#' @examples
#' set.seed(999)
#' x <- glSim(n.ind = 10, n.snp.nonstruc = 5e2, n.snp.struc = 5e2, ploidy = 2)
#' x
#' # Assess fraction of different alleles
#' system.time(xd <- bitwise.dist(x, threads = 1L))
#' xd
#' 
#' # Calculate Euclidean distance
#' system.time(xdt <- bitwise.dist(x, euclidean = TRUE, scale_missing = TRUE, threads = 1L))
#' xdt
#' 
#' \dontrun{
#' 
#' # This function is more efficient in both memory and speed than [dist()] for
#' # calculating Euclidean distance on genlight objects. For example, we can
#' # observe a clear speed increase when we attempt a calculation on 100k SNPs
#' # with 10% missing data:
#' 
#' set.seed(999)
#' mat <- matrix(sample(c(0:2, NA), 
#'                      100000 * 50, 
#'                      replace = TRUE, 
#'                      prob = c(0.3, 0.3, 0.3, 0.1)),
#'               nrow = 50)
#' glite <- new("genlight", mat, ploidy = 2)
#' 
#' # Default Euclidean distance 
#' system.time(dist(glite))
#' 
#' # Bitwise dist
#' system.time(bitwise.dist(glite, euclidean = TRUE, scale_missing = TRUE))
#' 
#' }
#==============================================================================#
bitwise.dist <- function(x, percent = TRUE, mat = FALSE, missing_match = TRUE, 
                         scale_missing = FALSE, euclidean = FALSE,
                         differences_only = FALSE, threads = 0L){
  stopifnot(inherits(x, c("genlight", "genclone", "genind", "snpclone")))
  # Stop if the ploidy of the genlight object is not consistent
  stopifnot(min(ploidy(x)) == max(ploidy(x))) 
  # Stop if the ploidy of the genlight object is not haploid or diploid
  stopifnot(min(ploidy(x)) == 2 || min(ploidy(x)) == 1)

  ploid     <- min(ploidy(x))
  ind.names <- indNames(x)
  inds      <- nInd(x)
  numPairs  <- nLoc(x)

  # Use Prevosti if this is a genclone or genind object
  if(!is(x, "genlight")){
    dist.mat <- prevosti.dist(x)
    if (percent == FALSE){
      dist.mat <- dist.mat*ploid*numPairs
    }
    if (mat == TRUE){
      dist.mat <- as.matrix(dist.mat)
    }
    # Return this matrix and exit function
    return(dist.mat)
  }

  # Continue function for genlight objects

  # Ensure that every SNPbin object has data for all chromosomes
  if (ploid == 2){
    x <- fix_uneven_diploid(x)
  }
  # Threads must be something that can cast to integer
  if(!is.numeric(threads) && !is.integer(threads) && threads >= 0)
  {
    stop("Threads must be a non-negative numeric or integer value")
  }

  # Cast parameters to proper types before passing them to C
  threads <- as.integer(threads)

  if (ploid == 1)
  {
    pairwise_dist <- .Call("bitwise_distance_haploid", x, missing_match, threads)
  }
  else
  {
    pairwise_dist <- .Call("bitwise_distance_diploid", x, missing_match, euclidean, differences_only, threads)
  }
  dist.mat <- pairwise_dist
  dim(dist.mat) <- c(inds,inds)
  colnames(dist.mat) <- ind.names
  rownames(dist.mat) <- ind.names
  nas <- NA.posi(x)
  if (scale_missing && sum(lengths(nas)) > 0) {
    adj      <- missing_correction(nas, nLoc(x))
    dist.mat <- dist.mat * adj
  }
  if (euclidean) {
    dist.mat <- sqrt(dist.mat)
  } else if (percent) {
    if (differences_only)
    {
      dist.mat <- dist.mat/(numPairs)
    }
    else
    {
      dist.mat <- dist.mat/(numPairs*ploid)
    }
  }
  if (mat == FALSE) {
    dist.mat <- as.dist(dist.mat)
  }
  return(dist.mat)
}

#==============================================================================#
#' Determines whether openMP is support on this system.
#'
#' @return FALSE if openMP is not supported, TRUE if it is
#' @author Zhian N. Kamvar, Jonah C. Brooks
#' 
#' @export
#' @examples
#' poppr_has_parallel()
#==============================================================================#
poppr_has_parallel <- function(){

  supported <- .Call("omp_test", PACKAGE = "poppr")

  if (supported == 0) {
    return(FALSE)
  } else {
    return(TRUE)
  }

}

#' Calculate correction for genetic distances
#'
#' @param nas a list of missing positions per sample
#' @param nloc the number of loci
#' @param mat a logical specifying whether or not a matrix should be returned
#'   (default: TRUE)
#'
#' @return an n x n matrix or a choose(n, 2) length vector of values that scale
#'   from 1 to the number of loci.
#' @noRd
missing_correction <- function(nas, nloc, mat = TRUE){
  res <- .Call("adjust_missing", nas, nloc, PACKAGE = "poppr")
  if (mat) {
    return(res)
  } else {
    return(res[lower.tri(res)])
  }
}

#==============================================================================#
#' Calculate the index of association between samples in a genlight object.
#' 
#' This function parses over a genlight object to calculate and return the index
#' of association for those samples.
#' 
#' @param x a [genlight][genlight-class] or [snpclone][snpclone-class] object.
#'   
#' @param missing_match a boolean determining whether missing data should be 
#'   considered a match. If TRUE (default) missing data at a locus will match 
#'   with any data at that locus in each comparison. If FALSE, missing data at a
#'   locus will cause all comparisons to return the maximum possible distance at
#'   that locus (ie, if sample 1 has missing data at locus 1, and sample 2 is
#'   heterozygous at locus 1, the distance at that locus will be 1. If sample 2
#'   was heterozygous or missing at locus 1, the distance would be 2.
#'   
#' @param differences_only a boolean determining how distance should be counted 
#'   for diploids. Whether TRUE or FALSE the distance between a heterozygous
#'   locus and a homozygous locus is 1. If FALSE (default) the distance between
#'   opposite homozygous loci is 2. If TRUE that distance counts as 1,
#'   indicating only that the two samples differ at that locus.
#'   
#' @param threads The maximum number of parallel threads to be used within this 
#'   function. A value of 0 (default) will attempt to use as many threads as
#'   there are available cores/CPUs. In most cases this is ideal. A value of 1
#'   will force the function to run serially, which may increase stability on
#'   some systems. Other values may be specified, but should be used with
#'   caution.
#'   
#' @return Index of association representing the samples in this genlight
#'   object.
#' @author Zhian N. Kamvar, Jonah C. Brooks
#'   
#' @export
#' @md
#' @seealso [win.ia()], [samp.ia()]
#' @keywords internal
#==============================================================================#
bitwise.ia <- function(x, missing_match=TRUE, differences_only=FALSE, threads=0){
  stopifnot(class(x)[1] %in% c("genlight", "snpclone"))
  # Stop if the ploidy of the genlight object is not consistent
  stopifnot(min(ploidy(x)) == max(ploidy(x))) 
  # Stop if the ploidy of the genlight object is not haploid or diploid
  stopifnot(min(ploidy(x)) == 2 || min(ploidy(x)) == 1)

  ploid     <- min(ploidy(x))

  # Threads must be something that can cast to integer
  if(!is.numeric(threads) && !is.integer(threads) && threads >= 0)
  {
    stop("Threads must be a non-negative numeric or integer value")
  }
  # Cast parameters to proper types before passing them to C
  threads <- as.integer(threads)
  # Ensure that every SNPbin object has data for all chromosomes
  if (ploid == 2){
    x  <- fix_uneven_diploid(x)
    IA <- .Call("association_index_diploid", 
                genlight = x, 
                missing_match = missing_match, 
                differences_only = differences_only, 
                requested_threads = threads, 
                PACKAGE = "poppr")
  }
  else if(ploid == 1)
  {
    IA <- .Call("association_index_haploid", x, missing_match, threads, 
                PACKAGE = "poppr")
  }
  else
  {
    stop("bitwise.ia only supports haploids and diploids")
  }
  return(IA)

}

#==============================================================================#
#' Calculate windows of the index of association for genlight objects.
#' 
#' Genlight objects can contain millions of loci. Since it does not make much 
#' sense to calculate the index of association over that many loci, this
#' function will scan windows across the loci positions and calculate the index
#' of association.
#' 
#' @param x a [genlight][genlight-class] or [snpclone][snpclone-class] object.
#'   
#' @param window an integer specifying the size of the window.
#'   
#' @param min.snps an integer specifying the minimum number of snps allowed per 
#'   window. If a window does not meet this criteria, the value will return as
#'   `NA`.
#'   
#' @param threads The maximum number of parallel threads to be used within this 
#'   function. Defaults to 1 thread, in which the function will run serially. A
#'   value of 0 will attempt to use as many threads as there are available
#'   cores/CPUs. In most cases this is ideal for speed. Note: this option is 
#'   passed to [bitwise.ia()] and does not parallelize the windowization process.
#'   
#' @param quiet if `FALSE` (default), a progress bar will be printed to the screen.
#' 
#' @param name_window if `TRUE` (default), the result vector will be named with
#'   the terminal position of the window. In the case where several chromosomes
#'   are represented, the position will be appended using a period/full stop.
#' 
#' @param chromosome_buffer *DEPRECATED* if `TRUE` (default), buffers will be placed 
#'   between adjacent chromosomal positions to prevent windows from spanning two
#'   chromosomes.
#'   
#' @return A value of the standardized index of association for all windows in
#'   each chromosome. 
#'   
#' @note this will calculate the standardized index of association from Agapow
#' and Burt, 2001. See [ia()] for details.
#' 
#' @author Zhian N. Kamvar, Jonah C. Brooks
#' 
#' @md
#' @export
#' @seealso [genlight][genlight-class], [snpclone][snpclone-class], [ia()], [samp.ia()], [bitwise.dist()]
#' @examples
#' 
#' # with structured snps assuming 1e4 positions
#' set.seed(999)
#' x <- glSim(n.ind = 10, n.snp.nonstruc = 5e2, n.snp.struc = 5e2, ploidy = 2)
#' position(x) <- sort(sample(1e4, 1e3))
#' res <- win.ia(x, window = 300L) # Calculate for windows of size 300
#' plot(res, type = "l")
#' 
#' \dontrun{
#' 
#' # unstructured snps
#' set.seed(999)
#' x <- glSim(n.ind = 10, n.snp.nonstruc = 1e3, ploidy = 2)
#' position(x) <- sort(sample(1e4, 1e3))
#' res <- win.ia(x, window = 300L) # Calculate for windows of size 300
#' plot(res, type = "l")
#' 
#' # Accounting for chromosome coordinates
#' set.seed(999)
#' x <- glSim(n.ind = 10, n.snp.nonstruc = 5e2, n.snp.struc = 5e2, ploidy = 2)
#' position(x) <- as.vector(vapply(1:10, function(x) sort(sample(1e3, 100)), integer(100)))
#' chromosome(x) <- rep(1:10, each = 100)
#' res <- win.ia(x, window = 100L)
#' plot(res, type = "l")
#' 
#' # Converting chromosomal coordinates to tidy data
#' library("dplyr")
#' library("tidyr")
#' res_tidy <- res %>% 
#'   data_frame(rd = ., chromosome = names(.)) %>% # create two column data frame
#'   separate(chromosome, into = c("chromosome", "position")) %>% # get the position info
#'   mutate(position = as.integer(position)) %>% # force position as integers
#'   mutate(chromosome = factor(chromosome, unique(chromosome))) # force order chromosomes
#' res_tidy
#' 
#' # Plotting with ggplot2
#' library("ggplot2")
#' ggplot(res_tidy, aes(x = position, y = rd, color = chromosome)) +
#'   geom_line() +
#'   facet_wrap(~chromosome, nrow = 1) +
#'   ylab(expression(bar(r)[d])) +
#'   xlab("terminal position of sliding window") +
#'   labs(caption = "window size: 100bp") + 
#'   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
#'   theme(legend.position = "top")
#'
#' }
#' 
#==============================================================================#
win.ia <- function(x, window = 100L, min.snps = 3L, threads = 1L, quiet = FALSE,
                   name_window = TRUE, chromosome_buffer = TRUE){
  stopifnot(is(x, "genlight"))
  if (is.null(position(x))) {
    position(x) <- seq(nLoc(x))
  }
  if (!chromosome_buffer) {
    msg <- paste("The argument `chromosome_buffer` has been deprecated as of",
                 "poppr version 1.8.0. All chromosomes are treated separately",
                 "by default.")
    warning(msg, immediate. = TRUE)
  }
  chromos <- !is.null(chromosome(x))
  xpos    <- position(x)
  quiet   <- should_poppr_be_quiet(quiet)
  winmat  <- make_windows(maxp = max(xpos), minp = 1L, window = window)
  if (chromos) {
    # Converting to character is necessary to avoid empty chromosomes.
    # See: https://twitter.com/ZKamvar/status/991114778415325184
    CHROM         <- as.character(chromosome(x))
    chrom_names   <- unique(CHROM)
    pos_per_chrom <- split(xpos, CHROM)[chrom_names]
    win_per_chrom <- ceiling(vapply(pos_per_chrom, max, integer(1))/window)
    names(win_per_chrom) <- chrom_names
    nwin                 <- sum(win_per_chrom)
    nchrom <- length(win_per_chrom) -> chromosomes_left
  } else {
    if (any(duplicated(position(x)))) {
      msg <- paste("There are duplicate positions in the data without any",
                   "chromosome structure. All positions must be unique.\n\n",
                   "Please the function chromosome() to add chromosome",
                   "coordinates or modify the positions.")
      stop(msg, call. = FALSE)
    }
    nwin             <- nrow(winmat)
    chromosomes_left <- 1L
  }
  res_mat <- vector(mode = "numeric", length = nwin)
  res_counter <- 1L
  if (name_window || chromos) res_names <- vector(mode = "character", length = nwin)
  if (!quiet) progbar <- txtProgressBar(style = 3)
  while (chromosomes_left > 0L) {
    chrom_counter   <- if (chromos) nchrom - chromosomes_left + 1L else 1L
    current_windows <- if (chromos) win_per_chrom[chrom_counter] else nwin 
    for (i in seq(current_windows)) {
      # Define the window
      the_window <- winmat[i, 1]:winmat[i, 2]
      the_chrom  <- if (chromos) chrom_names[chrom_counter] else TRUE
      posns      <- xpos %in% the_window
      # If there is chromosome structure, then add the current chromosome as an
      # additional constraint to the snps analyzed
      j <- if (chromos) posns & CHROM == the_chrom else posns
      
      # Check to make sure the SNP threshold is met. If not, set to NA
      if (sum(j) < min.snps) {
        res_mat[res_counter] <- NA_real_
      } else {
        res_mat[res_counter] <- bitwise.ia(x[, j], threads = threads)
      }
      if (name_window || chromos) {
        the_name <- if (chromos) paste(the_chrom, winmat[i, 2], sep = ".") else as.character(winmat[i, 2])
        res_names[res_counter] <- the_name
      }
      if (!quiet) {
        setTxtProgressBar(progbar, res_counter/nwin)
      }
      res_counter <- res_counter + 1L
    }
    # Decrement the number of chromosomes left to ensure the while loop can exit.
    chromosomes_left <- chromosomes_left - 1L
  }
  if (!quiet) cat("\n")
  if (name_window || chromos) names(res_mat) <- res_names
  return(res_mat)
}

#==============================================================================#
#' Calculate random samples of the index of association for genlight objects.
#' 
#' Genlight objects can contain millions of loci. Since it does not make much 
#' sense to calculate the index of association over that many loci, this
#' function will randomly sample sites to calculate the index of association.
#' 
#' @param x a [genlight][genlight-class] or [snpclone][snpclone-class] object.
#'   
#' @param n.snp the number of snps to be used to calculate standardized index
#' of association.
#' 
#' @param reps the number of times to perform the calculation.
#'   
#' @param threads The maximum number of parallel threads to be used within this 
#'   function. A value of 0 (default) will attempt to use as many threads as
#'   there are available cores/CPUs. In most cases this is ideal. A value of 1
#'   will force the function to run serially, which may increase stability on
#'   some systems. Other values may be specified, but should be used with
#'   caution.
#' 
#' @param quiet if `FALSE`, a progress bar will be printed to the screen.
#'
#' @details The index of association is a summary of linkage disequilibrium 
#'   among many loci. More information on the index of association can be found 
#'   associated with the funciton [ia()]. A value near or at zero
#'   indicator of linkage equilibrium, whereas values significantly greater than
#'   zero indicate linkage disequilibrium. However, if the observed variance in 
#'   distance among individuals is less than the expected, mildly negative 
#'   values may be observed (as the range of this index is negative one to one).
#'   This function will call the function [bitwise.ia()] for
#'   `reps` times to calculate the index of association over `n.snp`
#'   loci. The standardized index of association ('rbarD') will be calculated
#'   `reps` times. These esitmates of linkage disequilibrium from random
#'   genomic fractions can then be summarized (e.g., using a histogram) as an
#'   estimate of genome-wide linkage disequilibrium.
#'   
#' 
#' This function currently only works for objects of class genlight or snpclone
#' that are of a single ploidy level and that ploidy is either haploid or
#' diploid.
#' 
#'   
#' @note this will calculate the standardized index of association from Agapow
#' 2001. See [ia()] for details.
#' 
#' @return Index of association representing the samples in this genlight
#'   object.
#' @author Zhian N. Kamvar, Jonah C. Brooks
#'   
#' @export
#' @seealso [genlight][genlight-class],
#'    [snpclone][snpclone-class],
#'    [win.ia()],
#'    [ia()],
#'    [bitwise.dist()]
#'    [bitwise.ia()]
#' @examples
#' # with structured snps assuming 1e4 positions
#' set.seed(999)
#' x <- glSim(n.ind = 10, n.snp.nonstruc = 5e2, 
#'            n.snp.struc = 5e2, ploidy = 2,
#'            parallel = FALSE)
#' position(x) <- sort(sample(1e4, 1e3))
#' res <- samp.ia(x)
#' hist(res, breaks = "fd")
#' 
#' # with unstructured snps assuming 1e4 positions
#' set.seed(999)
#' x <- glSim(n.ind = 10, n.snp.nonstruc = 1e3, ploidy = 2)
#' position(x) <- sort(sample(1e4, 1e3))
#' res <- samp.ia(x)
#' hist(res, breaks = "fd")
#==============================================================================#
samp.ia <- function(x, n.snp = 100L, reps = 100L, threads = 1L, quiet = FALSE){
  stopifnot(is(x, "genlight"))
  nloc <- nLoc(x)
  quiet <- should_poppr_be_quiet(quiet)
  res_mat <- vector(mode = "numeric", length = reps)
  if (!quiet) progbar <- txtProgressBar(style = 3)
  for (i in seq(reps)){
    posns <- sample(nloc, n.snp)
    res_mat[i] <- bitwise.ia(x[, posns], threads = threads)
    if (!quiet){
      setTxtProgressBar(progbar, i/reps)
    }
  }
  if (!quiet) cat("\n")
  return(res_mat)
}
# Sat Aug 15 20:02:40 2015 ------------------------------
# 
# This function was used in place of bitwise.ia before it
# was fixed. Since it has no purpose now, it is being 
# commented out, but kept here for reference.
# 
# snpia <- function(x, threads = 1L){
#   nloc <- nLoc(x)
#   nind <- nInd(x)
#   np <- choose(nind, 2)
#   d_mat <- vapply(seq(nloc), function(i) as.vector(bitwise.dist(x[, i], percent = FALSE, threads = threads)), integer(np))
#   D <- rowSums(d_mat) 
#   SD <- sum(D)        
#   Sd <- colSums(d_mat)
#   Sd2 <- colSums(d_mat*d_mat)
#   Vo <- (sum(D*D) - (SD*SD)/np)/np
#   varj <- (Sd2 - (Sd*Sd)/np)/np
#   Ve <- sum(varj)
#   Svarij <- .Call("pairwise_covar", varj, PACKAGE = "poppr")
#   return((Vo - Ve)/(2 * sum(Svarij)))
# }
