local function velocidad_para_objetivo(g, l, hf, h0, angulo)
	-- local numerador = -2 * g * (l * l)
	-- local denominador = (hf - h0) - math.tan(math.rad(angulo)) * l * math.pow(math.cos(math.rad(angulo)), 2)

	local numerador = g * (l * l)
	local denominador = 2 * math.pow(math.cos(math.rad(angulo)), 2) * ((hf - h0) - l * math.tan(math.rad(angulo)))
	local solucion = math.sqrt(numerador / denominador)

	-- cuando no es un numero, tomar la siguiente solucion
	if solucion ~= solucion then
		solucion = math.sqrt(numerador / -denominador)
	end
	return solucion
end

-- aplicacion de la formula x=sqrt((mv^2)/k)
local function compresion_para_objetivo(v, k, m)
	local numerador = m * v * v
	local denominador = k
	return math.sqrt(numerador / denominador)
end

-- llegara al punto (x,y)??
function llegara(m, g, k, h0, hf, L, x, y, angulo)
	local v = velocidad_para_objetivo(g, L, hf, h0, angulo)
	local compresion_requerida = compresion_para_objetivo(v, k, m)
	if compresion_requerida > 1 then
		print(string.format("el resorte es demasiado debil para llegar a %.2f m/s, asi que no llegara", v))
	else
		print(
			string.format(
				"la compresion requerida para llegar al objetivo con %d grados es de %.2f m",
				angulo,
				compresion_requerida
			)
		)
	end
end

function input(prompt)
	io.write(prompt)
	return io.read("*n")
end

-- regresa los datos en el orden de los elementos de la variable nombres
function obtener_datos()
	local nombres = {
		h0 = "altura inicial (h0)",
		hf = "altura final (hf)",
		m = "masa (m)",
		k = "constante del resorte (k)",
		g = "gravedad (g)",
		x = "obstaculo (x)",
		y = "obstaculo (y)",
		L = "distancia al objetivo (L)",
	}
	local resultados = nombres
	for k, v in pairs(nombres) do
		resultados[k] = input(v)
	end
	return resultados
end

local datos = obtener_datos()

-- local h0 = 100
-- local hf = 0
-- local masa = 1
-- local constante_k = 20000
-- local gravedad = 9
-- local x_obstaculo = 300
-- local y_obstaculo = 500
-- local distancia = 400
--
-- local compresion = 0.98
-- local angulo = 45
--

for angulo = -20, 90, 1 do
	llegara(datos["m"], datos["g"], datos["k"], datos["h0"], datos["hf"], datos["L"], datos["x"], datos["y"], angulo)
end
