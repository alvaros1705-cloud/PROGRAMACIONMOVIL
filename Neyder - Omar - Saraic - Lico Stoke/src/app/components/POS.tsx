import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "./ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { ShoppingCart, Trash2, Plus, Minus, DollarSign } from "lucide-react";
import { Badge } from "./ui/badge";
import { toast } from "sonner";
import { useTheme } from "../context/ThemeContext";

interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  cost: number;
  stock: number;
  minStock: number;
}

interface CartItem {
  product: Product;
  quantity: number;
}

interface Sale {
  id: string;
  date: string;
  total: number;
  items: { productId: string; name: string; quantity: number; price: number }[];
}

interface POSProps {
  userId: string;
}

export function POS({ userId }: POSProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [products, setProducts] = useState<Product[]>([]);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("all");

  useEffect(() => {
    loadProducts();
  }, [userId]);

  const loadProducts = () => {
    const stored = localStorage.getItem(`licostoke_${userId}_products`);
    if (stored) {
      setProducts(JSON.parse(stored));
    }
  };

  const addToCart = (product: Product) => {
    if (product.stock <= 0) {
      toast.error("Producto sin stock");
      return;
    }

    const existingItem = cart.find(item => item.product.id === product.id);

    if (existingItem) {
      if (existingItem.quantity >= product.stock) {
        toast.error("No hay suficiente stock");
        return;
      }
      setCart(cart.map(item =>
        item.product.id === product.id
          ? { ...item, quantity: item.quantity + 1 }
          : item
      ));
    } else {
      setCart([...cart, { product, quantity: 1 }]);
    }
  };

  const updateQuantity = (productId: string, delta: number) => {
    setCart(cart.map(item => {
      if (item.product.id === productId) {
        const newQuantity = item.quantity + delta;
        if (newQuantity <= 0) return item;
        if (newQuantity > item.product.stock) {
          toast.error("No hay suficiente stock");
          return item;
        }
        return { ...item, quantity: newQuantity };
      }
      return item;
    }));
  };

  const removeFromCart = (productId: string) => {
    setCart(cart.filter(item => item.product.id !== productId));
  };

  const calculateTotal = () => {
    return cart.reduce((sum, item) => sum + (item.product.price * item.quantity), 0);
  };

  const completeSale = () => {
    if (cart.length === 0) {
      toast.error("El carrito está vacío");
      return;
    }

    const updatedProducts = products.map(product => {
      const cartItem = cart.find(item => item.product.id === product.id);
      if (cartItem) {
        return { ...product, stock: product.stock - cartItem.quantity };
      }
      return product;
    });

    const sale: Sale = {
      id: Date.now().toString(),
      date: new Date().toISOString(),
      total: calculateTotal(),
      items: cart.map(item => ({
        productId: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        price: item.product.price
      }))
    };

    const existingSales = localStorage.getItem(`licostoke_${userId}_sales`);
    const sales = existingSales ? JSON.parse(existingSales) : [];
    sales.push(sale);

    localStorage.setItem(`licostoke_${userId}_products`, JSON.stringify(updatedProducts));
    localStorage.setItem(`licostoke_${userId}_sales`, JSON.stringify(sales));

    setProducts(updatedProducts);
    setCart([]);

    toast.success(`Venta completada: $${sale.total.toLocaleString()}`);
  };

  const categories = ["all", ...Array.from(new Set(products.map(p => p.category)))];

  const filteredProducts = products.filter(p => {
    const matchesSearch = p.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === "all" || p.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const total = calculateTotal();

  return (
    <div className={`p-3 md:p-6 min-h-full ${isDark ? 'bg-[#1f2937]' : 'bg-[#F8FAFC]'}`}>
      <div className="mb-4 md:mb-6">
        <h1 className={`text-2xl md:text-3xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>Punto de Venta</h1>
        <p className={`text-sm md:text-base ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Registra transacciones</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 md:gap-6">
        <div className="lg:col-span-2">
          <Card className="bg-[#2c3545] border-[#3a4556]">
            <CardHeader className="p-3 md:p-6">
              <CardTitle className="text-base md:text-lg text-[#f1f5f9]">Productos</CardTitle>
              <div className="flex flex-col md:flex-row gap-2 md:gap-4 mt-3 md:mt-4">
                <Input
                  placeholder="Buscar..."
                  value={searchTerm}
                  onChange={e => setSearchTerm(e.target.value)}
                  className="flex-1 text-sm bg-[#1f2937] border-[#3a4556] text-[#f1f5f9] focus:border-[#d6a77a]"
                />
                <Select value={selectedCategory} onValueChange={setSelectedCategory}>
                  <SelectTrigger className="w-full md:w-48 bg-[#1f2937] border-[#3a4556] text-[#f1f5f9]">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent className="bg-[#2c3545] border-[#3a4556]">
                    <SelectItem value="all" className="text-[#f1f5f9]">Todas</SelectItem>
                    {categories.filter(c => c !== "all").map(cat => (
                      <SelectItem key={cat} value={cat} className="text-[#f1f5f9]">{cat}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </CardHeader>
            <CardContent className="p-3 md:p-6 pt-0">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 md:gap-3 max-h-[400px] md:max-h-[600px] overflow-y-auto">
                {filteredProducts.map(product => (
                  <Card
                    key={product.id}
                    className={`cursor-pointer transition-all active:scale-95 ${isDark ? 'bg-[#1f2937] border-[#3a4556] hover:border-[#C89B6D]' : 'bg-white border-gray-200 hover:border-[#C89B6D] hover:shadow-md'}`}
                    onClick={() => addToCart(product)}
                  >
                    <CardContent className="p-3 md:p-4">
                      <div className="flex justify-between items-start gap-2">
                        <div className="flex-1 min-w-0">
                          <h3 className={`font-semibold text-sm md:text-base truncate ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>{product.name}</h3>
                          <p className={`text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>{product.category}</p>
                          <p className="text-base md:text-lg font-bold mt-0.5 md:mt-1 text-[#C89B6D]">${product.price.toLocaleString()}</p>
                        </div>
                        <Badge variant={product.stock > 0 ? "outline" : "destructive"} className="text-xs flex-shrink-0 border-[#C89B6D] text-[#C89B6D]">
                          {product.stock}
                        </Badge>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="lg:col-span-1">
          <Card className={`lg:sticky lg:top-6 ${isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}`}>
            <CardHeader className="p-3 md:p-6">
              <CardTitle className={`flex items-center text-base md:text-lg ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>
                <ShoppingCart className="mr-2 h-4 w-4 md:h-5 md:w-5 text-[#C89B6D]" />
                Carrito
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 md:space-y-4 p-3 md:p-6 pt-0">
              {cart.length === 0 ? (
                <p className={`text-center py-6 md:py-8 text-sm md:text-base ${isDark ? 'text-[#94a3b8]' : 'text-gray-500'}`}>Carrito vacío</p>
              ) : (
                <>
                  <div className="space-y-2 md:space-y-3 max-h-[300px] md:max-h-[400px] overflow-y-auto">
                    {cart.map(item => (
                      <div key={item.product.id} className={`rounded-lg p-2 md:p-3 ${isDark ? 'border border-[#3a4556] bg-[#1f2937]' : 'border border-gray-200 bg-gray-50'}`}>
                        <div className="flex justify-between items-start mb-1.5 md:mb-2">
                          <div className="flex-1 min-w-0">
                            <h4 className={`font-medium text-xs md:text-sm truncate ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>{item.product.name}</h4>
                            <p className={`text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>
                              ${item.product.price.toLocaleString()} c/u
                            </p>
                          </div>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => removeFromCart(item.product.id)}
                            className={`h-7 w-7 p-0 md:h-8 md:w-8 text-red-500 ${isDark ? 'hover:bg-[#3a4556]' : 'hover:bg-gray-200'}`}
                          >
                            <Trash2 className="h-3 w-3 md:h-4 md:w-4" />
                          </Button>
                        </div>
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-1.5 md:gap-2">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => updateQuantity(item.product.id, -1)}
                              disabled={item.quantity <= 1}
                              className={`h-7 w-7 p-0 md:h-8 md:w-8 ${isDark ? 'bg-transparent border-[#3a4556] text-[#f1f5f9] hover:bg-[#3a4556]' : 'bg-white border-gray-300 text-[#0F172A] hover:bg-gray-100'}`}
                            >
                              <Minus className="h-3 w-3" />
                            </Button>
                            <span className={`w-6 md:w-8 text-center font-medium text-xs md:text-sm ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>{item.quantity}</span>
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => updateQuantity(item.product.id, 1)}
                              disabled={item.quantity >= item.product.stock}
                              className={`h-7 w-7 p-0 md:h-8 md:w-8 ${isDark ? 'bg-transparent border-[#3a4556] text-[#f1f5f9] hover:bg-[#3a4556]' : 'bg-white border-gray-300 text-[#0F172A] hover:bg-gray-100'}`}
                            >
                              <Plus className="h-3 w-3" />
                            </Button>
                          </div>
                          <p className="font-bold text-sm md:text-base text-[#C89B6D]">
                            ${(item.product.price * item.quantity).toLocaleString()}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className={`pt-3 md:pt-4 space-y-1.5 md:space-y-2 ${isDark ? 'border-t border-[#3a4556]' : 'border-t border-gray-200'}`}>
                    <div className={`flex justify-between text-base md:text-lg font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>
                      <span>Total:</span>
                      <span className="text-[#C89B6D]">${total.toLocaleString()}</span>
                    </div>
                  </div>

                  <Button
                    className="w-full bg-[#C89B6D] hover:bg-[#B8895D] text-white shadow-lg"
                    size="lg"
                    onClick={completeSale}
                  >
                    <DollarSign className="mr-2 h-4 w-4 md:h-5 md:w-5" />
                    <span className="text-sm md:text-base">Completar Venta</span>
                  </Button>

                  <Button
                    variant="outline"
                    className={`w-full ${isDark ? 'bg-transparent border-[#3a4556] text-[#f1f5f9] hover:bg-[#1f2937]' : 'bg-white border-gray-300 text-[#0F172A] hover:bg-gray-100'}`}
                    onClick={() => setCart([])}
                    size="sm"
                  >
                    <span className="text-sm md:text-base">Limpiar Carrito</span>
                  </Button>
                </>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
