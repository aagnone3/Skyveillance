import java.lang.Math;

// trilateration.cpp

/*
*  trilateration.cpp Library
*
* Created by Nico van Duijn on 9/25/15
*
* A library implementing trilateration on the Arduino platform.
*
* Solves the general problem of finding the coordinates of an unknown point when
* measured distances to a number (>=3) of know reference points are available.
* These can be absolute or relative distances. Note, however, that by using
* relative distances one degree of freedom is lost, which means one extra measurement
* is needed to obtain the same results/accuracy.
*
* The library provides options for finding the unknown point by means of
* linear least squares approximation (LLSQ), using an exact, linearized model
* of the problem as described here:
*
* http://inside.mines.edu/~whereman/talks/TurgutOzal-11-Trilateration.pdf
*
* The code used in this approach is heavily based on the MatrixMath library written by
* Charlie Matlack on 12/18/10 an RobH45345 on Arduino Forums, algorithm from
* NUMERICAL RECIPES: The Art of Scientific Computing,
*
* http://playground.arduino.cc/Code/MatrixMath
*
* as well as an added QR factorization algorithm from
*
* http://www.keithlantz.net/2012/05/qr-decomposition-using-householder-transformations/
*
* Alternatively, the library provides a computationally more expensive, but more exact
* solution with an implementation of the Levenberg-Marquart algorithm to find the optimal
* solution using non-linear least squares. (NLLSQ). This part was taken and adjusted from
* files written by Ron Babich in May 2008 and can be found in original form here:
*
* https://gist.github.com/rbabich/3539146
*
*/

// Includes


// Constants
static final double TOL = 1e-30; // smallest value allowed in cholesky_decomp() 
static final boolean VERBOSE = false;
static final int MAX_IT = 10000;
static final double INIT_LAMBDA = 0.0001;
static final int UP_FACTOR = 10;
static final int DOWN_FACTOR = 10;
static double TARGET_DERR = 1e-12;


// Matrix Printing Routine
void matrixPrint(double[] A, int m, int n, String label)
{
  // Uses tabs to separate numbers under assumption printed double width won't cause problems
  // A = input matrix (m x n)
  int i, j;
  println();
  println(label);
  for (i = 0; i<m; i++)
  {
    for (j = 0; j<n; j++)
    {
      print(A[n*i + j]);
      print("\t");
    }
    println();
  }
}

// Matrix Copy Routine
void matrixCopy(double[] A, int n, int m, double[] B)
{
  int i, j;
  for (i = 0; i < m; i++)
  {
    for (j = 0; j < n; j++)
    {
      B[n*i + j] = A[n*i + j];
    }
  }
}

//Matrix Multiplication Routine
void matrixMult(double[] A, double[] B, int m, int p, int n, double[] C)
{
  // C = A*B
  // A = input matrix (m x p)
  // B = input matrix (p x n)
  // m = number of rows in A
  // p = number of columns in A = number of rows in B
  // n = number of columns in B
  // C = output matrix = A*B (m x n)
  int i, j, k;
  for (i = 0; i < m; i++)
  {
    for (j = 0; j < n; j++)
    {
      C[n*i + j] = 0;
      for (k = 0; k<p; k++)
      {
        C[n*i + j] = C[n*i + j] + A[p*i + k] * B[n*k + j];
      }
    }
  }
}

//Matrix Addition Routine
void matrixAdd(double[] A, double[] B, int m, int n, double[] C)
{
  // A = input matrix (m x n)
  // B = input matrix (m x n)
  // m = number of rows in A = number of rows in B
  // n = number of columns in A = number of columns in B
  // C = output matrix = A+B (m x n)
  int i, j;
  for (i = 0; i < m; i++)
  {
    for (j = 0; j < n; j++)
    {
      C[n*i + j] = A[n*i + j] + B[n*i + j];
    }
  }
}

//Matrix Subtraction Routine
void matrixSub(double[] A, double[] B, int m, int n, double[] C)
{
  // A = input matrix (m x n)
  // B = input matrix (m x n)
  // m = number of rows in A = number of rows in B
  // n = number of columns in A = number of columns in B
  // C = output matrix = A-B (m x n)
  int i, j;
  for (i = 0; i<m; i++)
  {
    for (j = 0; j<n; j++)
    {
      C[n*i + j] = A[n*i + j] - B[n*i + j];
    }
  }
}

//Matrix Transpose Routine
void matrixTranspose(double[] A, int m, int n, double[] C)
{
  // A = input matrix (m x n)
  // m = number of rows in A
  // n = number of columns in A
  // C = output matrix = the transpose of A (n x m)
  int i, j;
  for (i = 0; i<m; i++)
  {
    for (j = 0; j<n; j++)
    {
      C[m*j + i] = A[n*i + j];
    }
  }
}

//Matrix Scale Routine
void matrixScale(double[] A, int m, int n, double k)
{
  for (int i = 0; i<m; i++)
  {
    for (int j = 0; j<n; j++)
    {
      A[n*i + j] = A[n*i + j] * k;
    }
  }
}

//Matrix Inversion Routine
int matrixInvert(double[] A, int n)
{
  // * This function inverts a matrix based on the Gauss Jordan method.
  // * Specifically, it uses partial pivoting to improve numeric stability.
  // * The algorithm is drawn from those presented in
  //   NUMERICAL RECIPES: The Art of Scientific Computing.
  // * The function returns 1 on success, 0 on failure.
  // * NOTE: The argument is ALSO the result matrix, meaning the input matrix is REPLACED
  // A = input matrix AND result matrix
  // n = number of rows = number of columns in A (n x n)
  int pivrow = -1;    // keeps track of current pivot row
  int k, i, j;    // k: overall index along diagonal; i: row index; j: col index
  int[] pivrows = new int[n]; // keeps track of rows swaps to undo at end
  double tmp;    // used for finding max value and making column swaps

  for (k = 0; k < n; k++) {
    // find pivot row, the row with biggest entry in current column
    tmp = 0;
    for (i = k; i < n; i++)
    {
      if (Math.abs(A[i*n + k]) >= tmp)  // 'Avoid using other functions inside Math.abs()?'
      {
        tmp = Math.abs(A[i*n + k]);
        pivrow = i;
      }
    }

    // check for singular matrix
    if (A[pivrow*n + k] == 0.0f)
    {
      //println("Inversion failed due to singular matrix");
      return 0;
    }

    // Execute pivot (row swap) if needed
    if (pivrow != k)
    {
      // swap row k with pivrow
      for (j = 0; j < n; j++)
      {
        tmp = A[k*n + j];
        A[k*n + j] = A[pivrow*n + j];
        A[pivrow*n + j] = tmp;
      }
    }
    pivrows[k] = pivrow;  // record row swap (even if no swap happened)

    tmp = 1.0f / A[k*n + k];  // invert pivot element
    A[k*n + k] = 1.0f;    // This element of input matrix becomes result matrix

    // Perform row reduction (divide every element by pivot)
    for (j = 0; j < n; j++)
    {
      A[k*n + j] = A[k*n + j] * tmp;
    }

    // Now eliminate all other entries in this column
    for (i = 0; i < n; i++)
    {
      if (i != k)
      {
        tmp = A[i*n + k];
        A[i*n + k] = 0.0f;  // The other place where in matrix becomes result mat
        for (j = 0; j < n; j++)
        {
          A[i*n + j] = A[i*n + j] - A[k*n + j] * tmp;
        }
      }
    }
  }

  // Done, now need to undo pivot row swaps by doing column swaps in reverse order
  for (k = n - 1; k >= 0; k--)
  {
    if (pivrows[k] != k)
    {
      for (i = 0; i < n; i++)
      {
        tmp = A[i*n + k];
        A[i*n + k] = A[i*n + pivrows[k]];
        A[i*n + pivrows[k]] = tmp;
      }
    }
  }
  return 1;
}

// QR Factorization
void QR(double[] A, int m, int n, double[] Q, double[] R)
{
  // Not a very efficient approach, but simple and effective
  // Written by Nico van Duijn, 9/13/2015
  // Source of algorithm (adjusted by me):
  // http://www.keithlantz.net/2012/05/qr-decomposition-using-householder-transformations/
  // A is the (m*n) matrix to be factorized A=Q*R

  double mag;
  double alpha;
  double[] u = new double[m];
  double[] v = new double[m];
  double[] vtrans = new double[m];
  double[] P = new double[m * m];
  double[] I = new double[m * m];
  double[] vvtrans = new double[m * m];
  double[] Rbackup = new double[m * m];
  double[] Qbackup = new double[m * m];
  matrixCopy(A, m, m, R); // Initialize R to A

  // Initialize Q, P, I to Identity
  for (int i = 0; i < m * m; i++)Q[i] = 0;
  for (int i = 0; i < m; i++)Q[i * n + i] = 1;
  for (int i = 0; i < m * m; i++)P[i] = 0;
  for (int i = 0; i < m; i++)P[i * n + i] = 1;
  for (int i = 0; i < m * m; i++)I[i] = 0;
  for (int i = 0; i < m; i++)I[i * n + i] = 1;

  for (int i = 0; i < n; i++)  //loop through all columns
  {
    for (int q = 0; q < m; q++)u[q] = 0; // set u and v to zero
    for (int q = 0; q < m; q++)v[q] = 0;

    mag = 0.0; //set mag to zero

    for (int j = i; j < m; j++)
    {
      u[j] = R[j * n + i];
      mag += u[j] * u[j];
    }
    mag = Math.sqrt(mag);

    alpha = u[i] < 0 ? mag : -mag;

    mag = 0.0;
    for (int j = i; j < m; j++)
    {
      v[j] = j == i ? u[j] + alpha : u[j];
      mag += v[j] * v[j];
    }
    mag = Math.sqrt(mag);

    if (mag < 0.0000000001) continue;

    for (int j = i; j < m; j++) v[j] /= mag;

    // P = I - (v * v.transpose()) * 2.0;
    matrixTranspose(v, m, 1, vtrans);
    matrixMult(v, vtrans, m, 1, m, vvtrans);
    matrixScale(vvtrans, m, m, 2.0);
    matrixSub(I, vvtrans, m, m, P);

    // R = P * R;
    matrixMult(P, R, m, m, m, Rbackup);
    matrixCopy(Rbackup, m, m, R);

    //Q = Q * P;
    matrixMult(Q, P, m, m, m, Qbackup);
    matrixCopy(Qbackup, m, m, Q);
  }

}

// Solves Ax=b using Cholesky decomposition 
void solveAxBCholesky(int n, double[] l, double[] x, double[] b)
{
  /*
  solve the equation Ax=b for a symmetric positive-definite matrix A,
  using the Cholesky decomposition A=LL^T.
  The matrix L is passed in "l".
  Elements above the diagonal are ignored.
  */

  int i, j;
  double sum;

  /* solve L*y = b for y (where x[] is used to store y) */

  for (i = 0; i<n; i++) {
    sum = 0;
    for (j = 0; j<i; j++)
      sum += l[i*n + j] * x[j];
    x[i] = (b[i] - sum) / l[i*n + i];
  }

  /* solve L^T*x = y for x (where x[] is used to store both y and x) */

  for (i = n - 1; i >= 0; i--) {
    sum = 0;
    for (j = i + 1; j<n; j++)
      sum += l[j*n + i] * x[j];
    x[i] = (x[i] - sum) / l[i*n + i];
  }
}

// Perform Cholesky decomposition 
boolean choleskyDecomp(int n, double[] l, double[] a)
{
  /*
  This function takes a symmetric, positive-definite matrix "a" and returns
  its (lower-triangular) Cholesky factor in "l".  Elements above the
  diagonal are neither used nor modified.  The same array may be passed
  as both l and a, in which case the decomposition is performed in place.
  */
  int i, j, k;
  double sum;

  for (i = 0; i<n; i++) {
    for (j = 0; j<i; j++) {
      sum = 0;
      for (k = 0; k<j; k++)
        sum += l[i*n + k] * l[j*n + k];
      l[i*n + j] = (a[i*n + j] - sum) / l[j*n + j];
    }

    sum = 0;
    for (k = 0; k<i; k++)
      sum += l[i*n + k] * l[i*n + k];
    sum = a[i*n + i] - sum;
    if (sum<TOL) return true; /* not positive-definite */
    l[i*n + i] = Math.sqrt(sum);
  }
  return false;
}

// Distance calculation
double dist(double x1, double y1, double z1, double x2, double y2, double z2)
{
  // Function to compute distance between two points
  return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1));
}

// Perform least-squares minimization using the Levenberg-Marquardt algorithm.
boolean levmarq(int npar, double[] par, int ny, double[] y, double[] dysq,  double[] fdata)
{
  /*
  The arguments are as follows :

  npar    number of parameters
    par     array of parameters to be varied
    ny      number of measurements to be fit
    y       array of measurements
    dysq    array of error in measurements, squared
    (set dysq = null for unweighted least - squares)
    func    function to be fit
    grad    gradient of "func" with respect to the input parameters
    fdata   pointer to any additional data required by the function

  */
  

  int x, i, j, it, nit;
  boolean ill;
  double lambda, up, down, mult, weight, err, newerr, derr, target_derr;
  double[] h = new double[npar*npar];
  double[] ch = new double[npar*npar];
  double[] g = new double[npar];
  double[] d = new double[npar];
  double[] delta = new double[npar];
  double[] newpar = new double[npar];
  
  nit = MAX_IT;
  lambda = INIT_LAMBDA;
  up = UP_FACTOR;
  down = 1.0/(DOWN_FACTOR);
  target_derr = TARGET_DERR;
  weight = 1;
  derr = newerr = 0; /* to avoid compiler warnings */

  /* calculate the initial error ("chi-squared") */
  err = errorFunc(par, ny, y, dysq, fdata);

  /* main iteration */
  for (it = 0; it<nit; it++) {

if (VERBOSE) {
      print("\niteration: ");
      println(it);
      print("err:");
      print(err);
      print("x:");
      print(par[0]);
      print("y:");
      print(par[1]);
      print("z:");
      println(par[2]);
      print("target derr is: ");
      println(target_derr);
      print("up is: ");
      println(up);
      print("down is: ");
      println(down);
}


    /* calculate the approximation to the Hessian and the "derivative" d */
    for (i = 0; i<npar; i++) {
      d[i] = 0;
      for (j = 0; j <= i; j++)
        h[i*npar + j] = 0;
    }
    for (x = 0; x<ny; x++) {
      if (dysq != null) weight = 1 / dysq[x]; /* for weighted least-squares */
      grad(g, par, x, fdata);
      for (i = 0; i<npar; i++) {
        d[i] += (y[x] - func(par, x, fdata))*g[i] * weight;
        for (j = 0; j <= i; j++)
          h[i*npar + j] += g[i] * g[j] * weight;
      }
    }

    /*  make a step "delta."  If the step is rejected, increase
    lambda and try again */
    mult = 1 + lambda;
    ill = true; /* ill-conditioned? */
    while (ill && (it < nit)) {
      for (i = 0; i<npar; i++)
        h[i*npar + i] = h[i*npar + i] * mult;

      ill = choleskyDecomp(npar, ch, h);

      if (!ill) {
        solveAxBCholesky(npar, ch, delta, d);
        for (i = 0; i<npar; i++)
          newpar[i] = par[i] + delta[i];
        newerr = errorFunc(newpar, ny, y, dysq, fdata);
        derr = newerr - err;
        ill = (derr > 0);
      }

if (VERBOSE) {
        println("New loop:");
        print("it = ");
        print(it);
        print("lambda = ");
        print(lambda,8);
        print("err = ");
        print(err,8);
        print("derr = ");
        println(derr,8);
        print("ill = ");
        println(ill);
}

      if (ill) {
        mult = (1 + lambda*up) / (1 + lambda);
        lambda *= up;
        it++;
      }
    }
    for (i = 0; i<npar; i++)
      par[i] = newpar[i];
    err = newerr;
    lambda *= down;

    if ((!ill) && (-derr<target_derr)) break;
  }

  return (it == nit);
}

// Calculate the error function (chi-squared) 
double errorFunc(double[] par, int ny, double[] y, double[] dysq, double[] fdata)
{
  int x;
  double res, e = 0;

  for (x = 0; x<ny; x++) {
    res = func(par, x, fdata) - y[x];
    if (dysq != null)  /* weighted least-squares */
      e += res*res / dysq[x];
    else
      e += res*res;
  }
  return e;
}

// Function to be optimized in NLLSQ 
double func(double[] params, int i, double[] antennas)
{
  return params[3] * Math.sqrt((antennas[i * 3] - params[0])*(antennas[i * 3] - params[0]) + (antennas[i * 3 + 1] - params[1])*(antennas[i * 3 + 1] - params[1]) + (antennas[i * 3 + 2] - params[2])*(antennas[i * 3 + 2] - params[2]));
}

// Gradient of function to be optimized in NLLSQ
void grad(double[] gradient, double[] params, int i, double[] antennas)
{
  double denom;
  denom = Math.sqrt((params[0])*(params[0]) - 2 * (antennas[i * 3])*(params[0]) + (params[1])*(params[1]) - 2 * (antennas[i * 3 + 1])*(params[1]) + (params[2])*(params[2]) - 2 * (antennas[i * 3 + 2])*(params[2]) + (antennas[i * 3])*(antennas[i * 3]) + (antennas[i * 3 + 1])*(antennas[i * 3 + 1]) + (antennas[i * 3 + 2])*(antennas[i * 3 + 2]));
  gradient[0] = ((params[0] - antennas[i * 3])*params[3]) / denom;
  gradient[1] = ((params[1] - antennas[i * 3 + 1] * params[3])) / denom;
  gradient[2] = ((params[2] - antennas[i * 3 + 2] * params[3])) / denom;
  gradient[3] = (denom);
}

// LLSQ Approx. Trilateration
void locateLLSQ(int numantennas, double[] antennas, double[] distances, double[] x)
{
  // function saves triangulated position in vector x
  // input *antennas holds
  // x1, y1, z1,
  // x2, y2, z2,
  // x3, y3, z3,
  // x4, y4, z4;
  // numantennas holds integer number of antennas (min 5)
  // double *distances holds pointer to array holding distances from each antenna
  // Theory used:
  // http://inside.mines.edu/~whereman/talks/TurgutOzal-11-Trilateration.pdf

  // define some locals
  int m = (numantennas - 1); // Number of rows in A
  int n = 3; // Number of columns in A (always three)
  if (m >= 4)n = 4; // Number of columns in A: three coordinates plus K
  double[] A = new double[m * n];
  double[] b = new double[m * 1];
  double r;
  double[] Atranspose = new double[n * m];
  double[] AtAinA = new double[n * m];
  double[] AtA = new double[n * n];

  //Calculating b vector
  for (int i = 0; i < m; i++)
  {
    r = dist(antennas[0], antennas[1], antennas[2], antennas[(i + 1) * 3], antennas[(i + 1) * 3 + 1], antennas[(i + 1) * 3 + 2]);
    b[i] = 0.5*(distances[0] * distances[0] - distances[i + 1] * distances[i + 1] + r * r); // If given exact distances
    if (n == 4)b[i] = 0.5 * r*r; // For the case when we calculate K, overwrite b
  }

if (VERBOSE) {
  // DEBUG
  matrixPrint(b, m, 1, "b");
}


  //Calculating A matrix
  for (int i = 0; i < m; i++)
  {
    A[i * n] = antennas[(i + 1) * 3] - antennas[0];         //xi-x1
    A[i * n + 1] = antennas[(i + 1) * 3 + 1] - antennas[1]; //yi-y1
    A[i * n + 2] = antennas[(i + 1) * 3 + 2] - antennas[2]; //zi-z1
    if (n == 4) A[i * n + 3] = -0.5 * (distances[0] * distances[0] - distances[i + 1] * distances[i + 1]); // for K
  }

if (VERBOSE) {
  // DEBUG
  matrixPrint(A, m, n, "A");
}

  matrixTranspose(A, m, n, Atranspose);
  matrixMult(Atranspose, A, n, m, n, AtA);

  if (matrixInvert(AtA, n) == 1)   //well behaved
  {
    matrixMult(AtA, Atranspose, n, n, m, AtAinA);
    matrixMult(AtAinA, b, n, m, 1, x);

  }
  else      // Ill-behaved A
  {

    double[] Q = new double[m * m];
    double[] Qtranspose = new double[m * m];
    double[] Qtransposeb = new double[m * 1];
    double[] R = new double[m * m];
    QR(A, m, n, Q, R);
    matrixTranspose(Q, m, m, Qtranspose);
    matrixMult(Qtranspose, b, m, m, 1, Qtransposeb);
    matrixInvert(R, m);
    matrixMult(R, Qtransposeb, m, m, 1, x);
  }

  // Adding back the reference point
  x[0] = x[0] + antennas[0];
  x[1] = x[1] + antennas[1];
  x[2] = x[2] + antennas[2];
  if (n == 4)x[3] = 1 / Math.sqrt(x[3]); // Calculate K
}

// NLLSQ Approximate trilateration 
void locateNLLSQ(int numantennas, double[] antennas, double[] distances, double[] x){
  int npar, ny;
  if (numantennas == 3){
    npar = 3; // Assume k=1
    ny = 3; // One measurement for each antenna
  }
  else if(numantennas >= 4){
    npar = 4; // x, y, z, K
    ny = numantennas; // one data point for each antenna
    }
  else{
    // We're screwed - THIS WONT WORK
    npar = 3; // Assume k=1
    ny = 3; // One measurement for each antenna
  }

  // perform least-squares minimization using the Levenberg-Marquardt using following parameters:
  levmarq(npar, x, ny, distances, null, antennas);
  
}

// Combination of NLLSQ and LLSQ for trilateration 
void locate(int numantennas, double[] antennas, double[] distances, double[] x){
  // LLSQ
  // locateLLSQ();

  // NLLSQ
  // locateNLLSQ();
}

void test() {
  print("Hello!\n");
}