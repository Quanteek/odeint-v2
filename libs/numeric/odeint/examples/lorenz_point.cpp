/* Example for the lorenz system with a 3D point type */

#include <iostream>

#include <boost/operators.hpp>

#include <boost/numeric/odeint.hpp>


//[point3D
class point3D :     
    boost::additive1< point3D ,
    boost::additive2< point3D , double ,
    boost::multiplicative2< point3D , double > > >
{
public:

    double x , y , z;

    point3D()
        : x( 0.0 ) , y( 0.0 ) , z( 0.0 )
    { }
    
    point3D( const double val )
        : x( val ) , y( val ) , z( val )
    { }

    point3D( const double _x , const double _y , const double _z  )
        : x( _x ) , y( _y ) , z( _z )
    { }

    point3D& operator+=( const point3D &p )
    {
        x += p.x; y += p.y; z += p.z;
        return *this;
    }

    point3D& operator*=( const double a )
    {
        x *= a; y *= a; z *= a;
        return *this;
    }

};
//]

//[point3D_abs_div
// only required for steppers with error control
point3D operator/( const point3D &p1 , const point3D &p2 )
{
    return point3D( p1.x/p2.x , p1.y/p2.y , p1.z/p1.z );
}

point3D abs( const point3D &p )
{
    return point3D( abs(p.x) , abs(p.y) , abs(p.z) );
}
//]


//[point3D_reduce
namespace boost { namespace numeric { namespace odeint {
// specialization of vector_space_reduce, only required for steppers with error control
template<>
struct vector_space_reduce< point3D >
{
    template< class Value , class Op >
    Value operator() ( const point3D &p , Op op , Value init )
    {
        init = op( init , p.x );
        init = op( init , p.y );
        init = op( init , p.z );
        return init;
    }
};
} } } 
//]

std::ostream& operator<<( std::ostream &out , const point3D &p )
{
    out << p.x << " " << p.y << " " << p.z;
    return out;
}

//[point3D_main
const double sigma = 10.0;
const double R = 28.0;
const double b = 8.0 / 3.0;

void lorenz( const point3D &x , point3D &dxdt , const double t )
{
    dxdt.x = sigma * ( x.y - x.x );
    dxdt.y = R * x.x - x.y - x.x * x.z;
    dxdt.z = -b * x.z + x.x * x.y;
}

using namespace boost::numeric::odeint;

int main()
{

    point3D x( 10.0 , 5.0 , 5.0 );
    //typedef runge_kutta4< point3D , double , point3D , 
    //                      double , vector_space_algebra > stepper;
    typedef runge_kutta_dopri5< point3D , double , point3D , 
                                double , vector_space_algebra > stepper;
    integrate_adaptive( make_controlled<stepper>( 1E-8 , 1E-8 ) , lorenz , x , 
                        0.0 , 10.0 , 0.1 );
    std::cout << x << std::endl;
}
//]
