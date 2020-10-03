class Usuario {
	const contenidosVistos = #{}
	
	/* Punto 1 */
	method vioCompleto(contenido) = contenido.fueVistoCompleto(self) // double-dispatch
	
	method vio(contenidoUnitario) = contenidosVistos.contains(contenidoUnitario)
	
	/* Punto 4.a */
	method generosQueVio() = 
		contenidosVistos.map{ contenido => contenido.genero() }.asSet()
		
	/* Punto 4.b */
	method generoPreferido() = 
		self.generosQueVio().max { genero => self.minutosVistos(genero) }
		
	method minutosVistos(genero) = 
		self.contenidosDelGenero(genero).sum { contenido => contenido.duracion() }
			
	method contenidosDelGenero(genero) = 
		contenidosVistos.filter{ contenido => contenido.esDeGenero(genero) }
}

class Contenido {
	method genero()
	
	method esDeGenero(genero) = genero == self.genero()
}

class ContenidoUnitario inherits Contenido {
	/* Punto 2 */
	const property duracion
	
	method fueVistoCompleto(usuario) = usuario.vio(self) // double-dispatch
}

class Pelicula inherits ContenidoUnitario {
	const property genero = ""
}

class Capitulo inherits ContenidoUnitario { 
	var property temporada
	
	override method genero() = temporada.genero()
}

class ContenidoCompuesto inherits Contenido {
	method componentes()
	
	/* Punto 2 */
	method duracion() = 
		self.componentes().sum{ componente => componente.duracion() }
	
	method fueVistoCompleto(usuario) =
		self.componentes().all { componente => usuario.vioCompleto(componente) }
}

class Temporada inherits ContenidoCompuesto {
	const capitulos = []
	const cantidadCapitulos = 2
	var property serie

	override method componentes() = capitulos
	
	override method fueVistoCompleto(usuario) = 
		self.estaCompleta() and super(usuario)
		
 	method estaCompleta() = capitulos.size() == cantidadCapitulos 
 	
 	method ultimoCapitulo() = capitulos.last()
 	
	override method genero() = serie.genero()
}

class Serie inherits ContenidoCompuesto {
	const temporadas = []
	const property genero = ""
	
	override method componentes() = temporadas
	
	/* Punto 3 */
	method ultimoCapitulo() = temporadas.last().ultimoCapitulo()
}