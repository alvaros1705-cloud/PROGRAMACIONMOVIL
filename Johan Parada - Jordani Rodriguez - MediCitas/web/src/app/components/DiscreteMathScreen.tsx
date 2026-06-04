import { useState } from "react";
import { Network, ChevronLeft } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent } from "./ui/card";
import { Badge } from "./ui/badge";
import BottomNav from "./BottomNav";

interface DiscreteMathScreenProps {
  onNavigate: (screen: string) => void;
}

const nodes = [
  "Paciente",
  "Medicina General",
  "Cardiología",
  "Laboratorio",
  "Farmacia",
  "Urgencias"
];

const edges = [
  ["Paciente", "Medicina General"],
  ["Paciente", "Cardiología"],
  ["Medicina General", "Laboratorio"],
  ["Medicina General", "Farmacia"],
  ["Cardiología", "Laboratorio"],
  ["Laboratorio", "Farmacia"],
  ["Urgencias", "Paciente"]
];

const adjacencyList: Record<string, string[]> = nodes.reduce(
  (acc, node) => ({ ...acc, [node]: [] }),
  {} as Record<string, string[]>
);

edges.forEach(([a, b]) => {
  adjacencyList[a].push(b);
  adjacencyList[b].push(a);
});

const nodePositions: Record<string, { x: number; y: number }> = {
  Paciente: { x: 100, y: 160 },
  "Medicina General": { x: 260, y: 80 },
  Cardiología: { x: 260, y: 240 },
  Laboratorio: { x: 420, y: 100 },
  Farmacia: { x: 420, y: 220 },
  Urgencias: { x: 580, y: 160 }
};

function findShortestPath(source: string, target: string) {
  const queue = [[source]];
  const visited = new Set([source]);

  while (queue.length > 0) {
    const path = queue.shift()!;
    const node = path[path.length - 1];

    if (node === target) {
      return path;
    }

    for (const neighbor of adjacencyList[node] || []) {
      if (!visited.has(neighbor)) {
        visited.add(neighbor);
        queue.push([...path, neighbor]);
      }
    }
  }

  return [];
}

function getPathEdges(path: string[]) {
  return path.slice(1).map((node, index) => [path[index], node] as [string, string]);
}

export default function DiscreteMathScreen({ onNavigate }: DiscreteMathScreenProps) {
  const [source, setSource] = useState("Paciente");
  const [target, setTarget] = useState("Farmacia");

  const path = findShortestPath(source, target);

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white px-6 py-6 sticky top-0 z-10">
        <div className="flex items-center justify-between mb-4">
          <button onClick={() => onNavigate('dashboard')} className="flex items-center space-x-2">
            <ChevronLeft className="w-6 h-6" />
            <span className="font-semibold">Volver</span>
          </button>
          <div className="flex items-center gap-2">
            <Network className="w-6 h-6" />
            <span className="text-lg font-semibold">Matemáticas Discretas</span>
          </div>
        </div>
        <p className="text-sm text-white/90">
          Explora cómo los grafos modelan la red de atención médica y cómo calcular rutas óptimas entre servicios.
        </p>
      </div>

      <div className="px-6 py-6 space-y-6">
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-xl font-semibold text-gray-900">Grafo de atención médica</h2>
                <p className="text-sm text-gray-600 mt-1">
                  Un grafo representa nodos (entidades) y aristas (relaciones). Aquí modelamos el flujo entre el paciente y los servicios médicos.
                </p>
              </div>
              <Badge className="bg-purple-100 text-purple-700">Grafos</Badge>
            </div>

            <div className="grid grid-cols-1 gap-4">
              <div className="relative bg-white rounded-3xl border border-gray-200 p-4">
                <div className="absolute inset-0 opacity-10 bg-gradient-to-br from-indigo-100 to-violet-100 rounded-3xl pointer-events-none" />
                <svg viewBox="0 0 700 340" className="relative w-full h-[340px]">
                  {edges.map(([from, to]) => {
                    const sourcePos = nodePositions[from];
                    const targetPos = nodePositions[to];
                    return (
                      <line
                        key={`${from}-${to}`}
                        x1={sourcePos.x}
                        y1={sourcePos.y}
                        x2={targetPos.x}
                        y2={targetPos.y}
                        stroke="#7c3aed"
                        strokeWidth={3}
                        opacity={0.25}
                      />
                    );
                  })}

                  {getPathEdges(path).map(([from, to]) => {
                    const sourcePos = nodePositions[from];
                    const targetPos = nodePositions[to];
                    return (
                      <line
                        key={`path-${from}-${to}`}
                        x1={sourcePos.x}
                        y1={sourcePos.y}
                        x2={targetPos.x}
                        y2={targetPos.y}
                        stroke="#2563eb"
                        strokeWidth={5}
                        opacity={0.9}
                      />
                    );
                  })}

                  {nodes.map((node) => {
                    const pos = nodePositions[node];
                    const isOnPath = path.includes(node);
                    return (
                      <g key={node}>
                        <circle
                          cx={pos.x}
                          cy={pos.y}
                          r={32}
                          fill={isOnPath ? "#4338ca" : "#eef2ff"}
                          stroke={isOnPath ? "#3730a3" : "#c7d2fe"}
                          strokeWidth={3}
                        />
                        <text
                          x={pos.x}
                          y={pos.y}
                          textAnchor="middle"
                          dominantBaseline="middle"
                          fill={isOnPath ? "#ffffff" : "#1f2937"}
                          className="text-sm font-semibold"
                        >
                          {node}
                        </text>
                      </g>
                    );
                  })}
                </svg>
                <div className="grid grid-cols-2 gap-3 mt-4 text-sm text-gray-700">
                  <div className="rounded-2xl bg-indigo-50 p-3">
                    <p className="font-semibold text-indigo-700">Nodos</p>
                    <p className="mt-2">Entidades del sistema de salud como Paciente, Laboratorio y Farmacia.</p>
                  </div>
                  <div className="rounded-2xl bg-violet-50 p-3">
                    <p className="font-semibold text-violet-700">Aristas</p>
                    <p className="mt-2">Conexiones directas que muestran cómo puede fluir el paciente entre servicios.</p>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-semibold text-gray-900">Camino mínimo</h2>
              <Badge className="bg-indigo-100 text-indigo-700">BFS</Badge>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-4">
                <div className="space-y-2">
                  <p className="text-sm text-gray-600">Origen</p>
                  <div className="flex flex-wrap gap-2">
                    {nodes.map((node) => (
                      <Button
                        key={`source-${node}`}
                        variant={source === node ? "secondary" : "outline"}
                        className="text-sm"
                        onClick={() => setSource(node)}
                      >
                        {node}
                      </Button>
                    ))}
                  </div>
                </div>

                <div className="space-y-2">
                  <p className="text-sm text-gray-600">Destino</p>
                  <div className="flex flex-wrap gap-2">
                    {nodes.map((node) => (
                      <Button
                        key={`target-${node}`}
                        variant={target === node ? "secondary" : "outline"}
                        className="text-sm"
                        onClick={() => setTarget(node)}
                      >
                        {node}
                      </Button>
                    ))}
                  </div>
                </div>
              </div>

              <div className="p-4 bg-indigo-50 rounded-3xl border border-indigo-100">
                <p className="text-sm text-gray-600 mb-3">Ruta más corta desde <strong>{source}</strong> hasta <strong>{target}</strong>:</p>
                {path.length > 0 ? (
                  <div className="space-y-3">
                    <div className="flex flex-wrap gap-2 items-center">
                      {path.map((step) => (
                        <span key={step} className="px-3 py-2 bg-white rounded-full border text-sm text-gray-900">
                          {step}
                        </span>
                      ))}
                    </div>
                    <p className="text-sm text-gray-700">
                      Este camino ilustra cómo un paciente puede pasar por varios servicios en una red de atención médica.
                    </p>
                  </div>
                ) : (
                  <p className="text-sm text-gray-700">No existe un camino entre los nodos seleccionados.</p>
                )}
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-r from-indigo-50 to-violet-50 border-indigo-100">
          <CardContent className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">Conceptos y ejemplos clínicos</h3>
            <ul className="space-y-3 text-sm text-gray-700">
              <li>
                <strong>Grafo de citas médicas:</strong> cada nodo puede ser un paciente, médico o clínica, y las aristas representan derivaciones o rutas de atención.
              </li>
              <li>
                <strong>Ruta óptima:</strong> en atención primaria, el camino más corto de <em>Paciente → Medicina General → Laboratorio → Farmacia</em> reduce tiempos y evita pasos innecesarios.
              </li>
              <li>
                <strong>Lista de adyacencia clínica:</strong> muestra qué especialidades están conectadas con el mismo paciente, útil para planificar flujos de atención.
              </li>
              <li>
                <strong>Ejemplo práctico:</strong> si un paciente necesita colesterol y control de presión, un algoritmo de grafo puede sugerir <em>Paciente → Medicina General → Farmacia</em> en lugar de derivarlo a Urgencias primero.
              </li>
            </ul>
          </CardContent>
        </Card>
      </div>

      <BottomNav currentScreen="dashboard" onNavigate={onNavigate} />
    </div>
  );
}
