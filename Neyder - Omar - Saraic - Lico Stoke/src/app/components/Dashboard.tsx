import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell } from "recharts";
import { DollarSign, Package, TrendingUp, ShoppingCart } from "lucide-react";
import { useEffect, useState } from "react";
import { useTheme } from "../context/ThemeContext";

interface Sale {
  id: string;
  date: string;
  total: number;
  items: { productId: string; quantity: number; price: number }[];
}

interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  stock: number;
}

interface DashboardProps {
  userId: string;
}

export function Dashboard({ userId }: DashboardProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [sales, setSales] = useState<Sale[]>([]);
  const [products, setProducts] = useState<Product[]>([]);

  useEffect(() => {
    const storedSales = localStorage.getItem(`licostoke_${userId}_sales`);
    const storedProducts = localStorage.getItem(`licostoke_${userId}_products`);

    if (storedSales) setSales(JSON.parse(storedSales));
    if (storedProducts) setProducts(JSON.parse(storedProducts));
  }, [userId]);

  const totalRevenue = sales.reduce((sum, sale) => sum + sale.total, 0);
  const totalProducts = products.length;
  const lowStock = products.filter(p => p.stock < 10).length;
  const totalSales = sales.length;

  const last7Days = Array.from({ length: 7 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - (6 - i));
    return date.toISOString().split('T')[0];
  });

  const salesByDay = last7Days.map(date => {
    const daySales = sales.filter(s => s.date.startsWith(date));
    const total = daySales.reduce((sum, s) => sum + s.total, 0);
    return {
      date: new Date(date).toLocaleDateString('es-ES', { weekday: 'short' }),
      ventas: total
    };
  });

  const categorySales = products.reduce((acc, product) => {
    const productSales = sales.reduce((sum, sale) => {
      const item = sale.items.find(i => i.productId === product.id);
      return sum + (item ? item.quantity * item.price : 0);
    }, 0);

    if (!acc[product.category]) {
      acc[product.category] = 0;
    }
    acc[product.category] += productSales;
    return acc;
  }, {} as Record<string, number>);

  const categoryData = Object.entries(categorySales).map(([name, value]) => ({
    name,
    value
  }));

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8'];

  const topProducts = products
    .map(product => {
      const sold = sales.reduce((sum, sale) => {
        const item = sale.items.find(i => i.productId === product.id);
        return sum + (item ? item.quantity : 0);
      }, 0);
      return { ...product, sold };
    })
    .sort((a, b) => b.sold - a.sold)
    .slice(0, 5)
    .map(p => ({ name: p.name, vendidos: p.sold }));

  return (
    <div className={`p-3 md:p-6 space-y-4 md:space-y-6 min-h-full ${isDark ? 'bg-[#1f2937]' : 'bg-[#F8FAFC]'}`}>
      <div>
        <h1 className={`text-2xl md:text-3xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>Dashboard</h1>
        <p className={`text-sm md:text-base ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Resumen general de LicoStoke</p>
      </div>

      <div className="grid gap-3 md:gap-4 grid-cols-2 lg:grid-cols-4">
        <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 p-3 md:p-6">
            <CardTitle className={`text-xs md:text-sm font-medium ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>Ingresos</CardTitle>
            <DollarSign className="h-3 w-3 md:h-4 md:w-4 text-[#C89B6D]" />
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <div className={`text-lg md:text-2xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>${totalRevenue.toLocaleString()}</div>
            <p className={`text-xs ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Ventas</p>
          </CardContent>
        </Card>

        <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 p-3 md:p-6">
            <CardTitle className={`text-xs md:text-sm font-medium ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>Productos</CardTitle>
            <Package className="h-3 w-3 md:h-4 md:w-4 text-[#C89B6D]" />
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <div className={`text-lg md:text-2xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>{totalProducts}</div>
            <p className={`text-xs ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>{lowStock} bajo</p>
          </CardContent>
        </Card>

        <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 p-3 md:p-6">
            <CardTitle className={`text-xs md:text-sm font-medium ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>Ventas</CardTitle>
            <ShoppingCart className="h-3 w-3 md:h-4 md:w-4 text-[#C89B6D]" />
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <div className={`text-lg md:text-2xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>{totalSales}</div>
            <p className={`text-xs ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Total</p>
          </CardContent>
        </Card>

        <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 p-3 md:p-6">
            <CardTitle className={`text-xs md:text-sm font-medium ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>Promedio</CardTitle>
            <TrendingUp className="h-3 w-3 md:h-4 md:w-4 text-[#C89B6D]" />
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <div className={`text-lg md:text-2xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>
              ${totalSales > 0 ? Math.round(totalRevenue / totalSales).toLocaleString() : 0}
            </div>
            <p className={`text-xs ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Ticket</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-3 md:gap-4 grid-cols-1 lg:grid-cols-2">
        <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
          <CardHeader className="p-3 md:p-6">
            <CardTitle className={`text-sm md:text-base ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>Ventas Últimos 7 Días</CardTitle>
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={salesByDay}>
                <CartesianGrid strokeDasharray="3 3" stroke={isDark ? '#3a4556' : '#e5e7eb'} />
                <XAxis dataKey="date" stroke={isDark ? '#94a3b8' : '#6b7280'} />
                <YAxis stroke={isDark ? '#94a3b8' : '#6b7280'} />
                <Tooltip contentStyle={{ backgroundColor: isDark ? '#2c3545' : '#ffffff', border: `1px solid ${isDark ? '#3a4556' : '#e5e7eb'}`, borderRadius: '8px' }} />
                <Legend />
                <Line type="monotone" dataKey="ventas" stroke="#C89B6D" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
          <CardHeader className="p-3 md:p-6">
            <CardTitle className={`text-sm md:text-base ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>Ventas por Categoría</CardTitle>
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={categoryData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#C89B6D"
                  dataKey="value"
                >
                  {categoryData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ backgroundColor: isDark ? '#2c3545' : '#ffffff', border: `1px solid ${isDark ? '#3a4556' : '#e5e7eb'}`, borderRadius: '8px' }} />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
        <CardHeader className="p-3 md:p-6">
          <CardTitle className={`text-sm md:text-base ${isDark ? 'text-[#f1f5f9]' : 'text-[#1E293B]'}`}>Productos Más Vendidos</CardTitle>
        </CardHeader>
        <CardContent className="p-3 md:p-6 pt-0">
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={topProducts}>
              <CartesianGrid strokeDasharray="3 3" stroke={isDark ? '#3a4556' : '#e5e7eb'} />
              <XAxis dataKey="name" stroke={isDark ? '#94a3b8' : '#6b7280'} />
              <YAxis stroke={isDark ? '#94a3b8' : '#6b7280'} />
              <Tooltip contentStyle={{ backgroundColor: isDark ? '#2c3545' : '#ffffff', border: `1px solid ${isDark ? '#3a4556' : '#e5e7eb'}`, borderRadius: '8px' }} />
              <Legend />
              <Bar dataKey="vendidos" fill="#C89B6D" />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  );
}
