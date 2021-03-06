class Cbc < Formula
  desc "Mixed integer linear programming solver"
  homepage "https://projects.coin-or.org/Cbc"
  url "https://www.coin-or.org/download/source/Cbc/Cbc-2.9.8.tgz"
  sha256 "ff6860400a1390170f9cb19fab6f21c1997138d285b5f225be04c4642c9a7bea"
  head "https://projects.coin-or.org/svn/Cbc/trunk"

  depends_on "homebrew/science/asl" => :optional
  depends_on "homebrew/science/glpk" => :optional
  depends_on "homebrew/science/openblas" => :optional

  asl_dep = (build.with? "asl") ? ["with-asl"] : []
  glpk_dep = (build.with? "glpk") ? ["with-glpk"] : []
  openblas_dep = (build.with? "openblas") ? ["with-openblas"] : []

  depends_on "homebrew/science/mumps" => [:optional, "without-mpi"] + openblas_dep
  depends_on "homebrew/science/suite-sparse" => [:optional] + openblas_dep

  mumps_dep = (build.with? "mumps") ? ["with-mumps"] : []
  suite_sparse_dep = (build.with? "suite-sparse") ? ["with-suite-sparse"] : []

  depends_on "clp" => (asl_dep + glpk_dep + openblas_dep + mumps_dep + suite_sparse_dep)
  depends_on "cgl"
  depends_on :fortran

  def install
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--datadir=#{pkgshare}",
            "--includedir=#{include}/cbc",
            "--enable-cbc-parallel",
            "--with-sample-datadir=#{Formula["coin_data_sample"].opt_pkgshare}/coin/Data/Sample",
            "--with-netlib-datadir=#{Formula["coin_data_netlib"].opt_pkgshare}/coin/Data/Netlib",
            "--with-dot",
           ]

    if build.with? "glpk"
      args << "--with-glpk-lib=-L#{Formula["glpk"].opt_lib} -lglpk"
      args << "--with-glpk-incdir=#{Formula["glpk"].opt_include}"
    end

    if build.with? "asl"
      args << "--with-asl-incdir=#{Formula["asl"].opt_include}/asl"
      args << "--with-asl-lib=-L#{Formula["asl"].opt_lib} -lasl"
    end

    system "./configure", *args

    system "make"
    system "make", "test"
    ENV.deparallelize # make install fails in parallel.
    system "make", "install"
  end
end
