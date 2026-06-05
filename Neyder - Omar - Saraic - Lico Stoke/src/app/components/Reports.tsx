import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "./ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, LineChart, Line } from "recharts";
import { FileText, TrendingUp, Calendar } from "lucide-react";
import { Badge } from "./ui/badge";
import { useTheme } from "../context/ThemeContext";

interface Sale {
  id: string;
  date: string;
  total: number;
  items: { productId: string; name: string; quantity: number; price: number }[];
}

interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  cost: number;
  stock: number;
}

interface ReportsProps {
  userId: string;
}

export function Reports({ userId }: ReportsProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [sales, setSales] = useState<Sale[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [period, setPeriod] = useState("7days");

  useEffect(() => {
    const storedSales = localStorage.getItem(`licostoke_${userId}_sales`);
    const storedProducts = localStorage.getItem(`licostoke_${userId}_products`);

    if (storedSales) setSales(JSON.parse(storedSales));
    if (storedProducts) setProducts(JSON.parse(storedProducts));
  }, [userId]);

  const getDaysAgo = (days: number) => {
    const date = new Date();
    date.setDate(date.getDate() - days);
    return date;
  };

  const filterSalesByPeriod = () => {
    const now = new Date();
    const periodDays = period === "7days" ? 7 : period === "30days" ? 30 : period === "90days" ? 90 : 365;
    const startDate = getDaysAgo(periodDays);

    return sales.filter(sale => new Date(sale.date) >= startDate);
  };

  const filteredSales = filterSalesByPeriod();

  const totalRevenue = filteredSales.reduce((sum, sale) => sum + sale.total, 0);

  const totalCost = filteredSales.reduce((sum, sale) => {
    const saleCost = sale.items.reduce((itemSum, item) => {
      const product = products.find(p => p.id === item.productId);
      if (product && product.cost) {
        return itemSum + (product.cost * item.quantity);
      }
      return itemSum;
    }, 0);
    return sum + saleCost;
  }, 0);

  const totalProfit = totalRevenue - totalCost;

  const productSales = products.map(product => {
    const sold = filteredSales.reduce((sum, sale) => {
      const item = sale.items.find(i => i.productId === product.id);
      return sum + (item ? item.quantity : 0);
    }, 0);

    const revenue = filteredSales.reduce((sum, sale) => {
      const item = sale.items.find(i => i.productId === product.id);
      return sum + (item ? item.quantity * item.price : 0);
    }, 0);

    return {
      ...product,
      sold,
      revenue,
      profit: revenue - (product.cost * sold)
    };
  }).sort((a, b) => b.revenue - a.revenue);

  const topProducts = productSales.slice(0, 10);

  const dailySales = (() => {
    const days = period === "7days" ? 7 : period === "30days" ? 30 : 30;
    return Array.from({ length: days }, (_, i) => {
      const date = new Date();
      date.setDate(date.getDate() - (days - 1 - i));
      const dateStr = date.toISOString().split('T')[0];

      const daySales = filteredSales.filter(s => s.date.startsWith(dateStr));
      const revenue = daySales.reduce((sum, s) => sum + s.total, 0);

      return {
        date: date.toLocaleDateString('es-ES', { month: 'short', day: 'numeric' }),
        ventas: revenue
      };
    });
  })();

  const categorySales = products.reduce((acc, product) => {
    const revenue = filteredSales.reduce((sum, sale) => {
      const item = sale.items.find(i => i.productId === product.id);
      return sum + (item ? item.quantity * item.price : 0);
    }, 0);

    if (!acc[product.category]) {
      acc[product.category] = { revenue: 0, sold: 0 };
    }

    const sold = filteredSales.reduce((sum, sale) => {
      const item = sale.items.find(i => i.productId === product.id);
      return sum + (item ? item.quantity : 0);
    }, 0);

    acc[product.category].revenue += revenue;
    acc[product.category].sold += sold;
    return acc;
  }, {} as Record<string, { revenue: number; sold: number }>);

  const categoryData = Object.entries(categorySales)
    .map(([category, data]) => ({
      category,
      ventas: data.revenue,
      unidades: data.sold
    }))
    .sort((a, b) => b.ventas - a.ventas);

  return (
    <div className={`p-3 md:p-6 space-y-4 md:space-y-6 min-h-full ${isDark ? 'bg-[#1f2937]' : 'bg-[#F8FAFC]'}`}>
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div className="flex-1 min-w-0">
          <h1 className={`text-2xl md:text-3xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>Reportes</h1>
          <p className={`text-sm md:text-base ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Análisis de ventas</p>
        </div>
        <Select value={period} onValueChange={setPeriod}>
          <SelectTrigger className={`w-full sm:w-48 ${isDark ? 'bg-[#2c3545] border-[#3a4556] text-[#f1f5f9]' : 'bg-white border-gray-300 text-[#0F172A]'}`}>
            <SelectValue />
          </SelectTrigger>
          <SelectContent className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
            <SelectItem value="7days" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Últimos 7 días</SelectItem>
            <SelectItem value="30days" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Últimos 30 días</SelectItem>
            <SelectItem value="90days" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Últimos 90 días</SelectItem>
            <SelectItem value="year" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Último año</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="grid gap-3 md:gap-4 grid-cols-1 sm:grid-cols-2 md:grid-cols-3">
        <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 p-3 md:p-6">
            <CardTitle className={`text-xs md:text-sm font-medium ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>Ingresos</CardTitle>
            <TrendingUp className="h-3 w-3 md:h-4 md:w-4 text-[#C89B6D]" />
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <div className={`text-lg md:text-2xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>${totalRevenue.toLocaleString()}</div>
            <p className={`text-xs ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>
              {filteredSales.length} ventas
            </p>
          </CardContent>
        </Card>

        <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 p-3 md:p-6">
            <CardTitle className={`text-xs md:text-sm font-medium ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>Ganancia</CardTitle>
            <TrendingUp className="h-3 w-3 md:h-4 md:w-4 text-[#4ade80]" />
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <div className="text-lg md:text-2xl font-bold text-[#4ade80]">
              ${totalProfit.toLocaleString()}
            </div>
            <p className={`text-xs ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>
              {totalRevenue > 0 ? ((totalProfit / totalRevenue) * 100).toFixed(1) : 0}% margen
            </p>
          </CardContent>
        </Card>

        <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 p-3 md:p-6">
            <CardTitle className={`text-xs md:text-sm font-medium ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>Promedio</CardTitle>
            <FileText className="h-3 w-3 md:h-4 md:w-4 text-[#C89B6D]" />
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <div className={`text-lg md:text-2xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>
              ${filteredSales.length > 0 ? Math.round(totalRevenue / filteredSales.length).toLocaleString() : 0}
            </div>
            <p className={`text-xs ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Por venta</p>
          </CardContent>
        </Card>
      </div>

      <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
        <CardHeader className="p-3 md:p-6">
          <CardTitle className={`text-sm md:text-base ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>Ventas Diarias</CardTitle>
        </CardHeader>
        <CardContent className="p-3 md:p-6 pt-0">
          <ResponsiveContainer width="100%" height={250}>
            <LineChart data={dailySales}>
              <CartesianGrid strokeDasharray="3 3" stroke={isDark ? '#3a4556' : '#e2e8f0'} />
              <XAxis dataKey="date" stroke={isDark ? '#94a3b8' : '#64748b'} />
              <YAxis stroke={isDark ? '#94a3b8' : '#64748b'} />
              <Tooltip contentStyle={{ backgroundColor: isDark ? '#2c3545' : '#ffffff', border: `1px solid ${isDark ? '#3a4556' : '#e2e8f0'}`, borderRadius: '8px', color: isDark ? '#f1f5f9' : '#0F172A' }} />
              <Legend />
              <Line type="monotone" dataKey="ventas" stroke="#C89B6D" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
        <CardHeader className="p-3 md:p-6">
          <CardTitle className={`text-sm md:text-base ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>Ventas por Categoría</CardTitle>
        </CardHeader>
        <CardContent className="p-3 md:p-6 pt-0">
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={categoryData}>
              <CartesianGrid strokeDasharray="3 3" stroke={isDark ? '#3a4556' : '#e2e8f0'} />
              <XAxis dataKey="category" stroke={isDark ? '#94a3b8' : '#64748b'} />
              <YAxis yAxisId="left" orientation="left" stroke="#C89B6D" />
              <YAxis yAxisId="right" orientation="right" stroke="#4ade80" />
              <Tooltip contentStyle={{ backgroundColor: isDark ? '#2c3545' : '#ffffff', border: `1px solid ${isDark ? '#3a4556' : '#e2e8f0'}`, borderRadius: '8px', color: isDark ? '#f1f5f9' : '#0F172A' }} />
              <Legend />
              <Bar yAxisId="left" dataKey="ventas" fill="#C89B6D" name="Ingresos ($)" />
              <Bar yAxisId="right" dataKey="unidades" fill="#4ade80" name="Unidades" />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
        <CardHeader className="p-3 md:p-6">
          <CardTitle className={`text-sm md:text-base ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>Top 10 Productos</CardTitle>
        </CardHeader>
        <CardContent className="p-0 md:p-6">
          <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow className={isDark ? 'border-[#3a4556]' : 'border-gray-200'}>
                <TableHead className={`text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Producto</TableHead>
                <TableHead className={`hidden md:table-cell text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Categoría</TableHead>
                <TableHead className={`text-right text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Vendidos</TableHead>
                <TableHead className={`text-right text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Ingresos</TableHead>
                <TableHead className={`hidden sm:table-cell text-right text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Ganancia</TableHead>
                <TableHead className={`hidden lg:table-cell text-right text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Margen</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {topProducts.map(product => (
                <TableRow key={product.id} className={isDark ? 'border-[#3a4556]' : 'border-gray-200'}>
                  <TableCell className={`font-medium text-xs md:text-sm ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>
                    <div>
                      <div>{product.name}</div>
                      <div className={`text-xs ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'} md:hidden`}>{product.category}</div>
                    </div>
                  </TableCell>
                  <TableCell className="hidden md:table-cell">
                    <Badge variant="outline" className="text-xs border-[#C89B6D] text-[#C89B6D]">{product.category}</Badge>
                  </TableCell>
                  <TableCell className={`text-right text-xs md:text-sm ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>{product.sold}</TableCell>
                  <TableCell className={`text-right text-xs md:text-sm ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>${product.revenue.toLocaleString()}</TableCell>
                  <TableCell className="hidden sm:table-cell text-right text-xs md:text-sm text-[#4ade80]">
                    ${product.profit.toLocaleString()}
                  </TableCell>
                  <TableCell className={`hidden lg:table-cell text-right text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>
                    {product.revenue > 0 ? ((product.profit / product.revenue) * 100).toFixed(1) : 0}%
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
