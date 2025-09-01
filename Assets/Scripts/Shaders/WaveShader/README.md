# A Unity Shader Graph using Gerstner Waves

A shader graph implementation of this catlike coding tutorial: https://catlikecoding.com/unity/tutorials/flow/waves/

From catlike coding: "Gerstner waves are named after František Josef Gerstner, who discovered them. They're also known as trochoidal waves, named after their shape, or periodic surface gravity waves, which describes their physical nature."

For our vertex displacement, we accumulate three Gerstner waves moving in slightly different directions along the x,z plane. Details for how these functions are derived are included in the doc above but we eventually arrive at:

### Phase function f (ith wave):

$$
f_i = k_i \Big( D_i \cdot 
\begin{bmatrix} x \\ z \end{bmatrix} - c_i t \Big),
\quad
k_i = \frac{2\pi}{\lambda_i},
\quad
c_i = \sqrt{\frac{g}{k_i}}
$$

k = Wave number, or how tightly packed the crests are (inversely proportioanal to wavelength lambda)
c = How fast the wave moves (g is our gravity constant)

### Vertex displacement P (summing n waves):

$$
P =
\begin{bmatrix}
x + \sum_{i=1}^{n} D_{x,i} \ a_i \cos f_i \\
\sum_{i=1}^{n} a_i \sin f_i \\
z + \sum_{i=1}^{n} D_{z,i} \ a_i \cos f_i
\end{bmatrix}
$$

D = Our 2D direction vector (x,z unit vector, e.g. (1,0) travels along X only)
a is our amplitude = s/k for a given wave. (s is an initial parameter describing the steepness of our wave)

### Normal calculation:
To calculate our lighting, and to place our boat, we need the normal vector of the wave at any x,z position. (The 2D plane if you're looking down at our scene from above.) To calculate this, we need to take the cross product of the partial derivatives (slopes) of the surface in the x (ie, the tangent) and z (ie, the binormal) directions. We end up with these equations for our summed tangent and binormal:

$$
T =
\begin{bmatrix}
1 - \sum_{i=1}^{n} D_{x,i}^2 \, s_i \sin f_i \\
\sum_{i=1}^{n} D_{x,i} \, s_i \cos f_i \\
- \sum_{i=1}^{n} D_{x,i} D_{z,i} \, s_i \sin f_i
\end{bmatrix}
$$

$$
B =
\begin{bmatrix}
- \sum_{i=1}^{n} D_{x,i} D_{z,i} \, s_i \sin f_i \\
\sum_{i=1}^{n} D_{z,i} \, s_i \cos f_i \\
1 - \sum_{i=1}^{n} D_{z,i}^2 \, s_i \sin f_i
\end{bmatrix}
$$

Our normal vector N:

$$
N = \frac{B \times T}{\lVert B \times T \rVert}
$$
