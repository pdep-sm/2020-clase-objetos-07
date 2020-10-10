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
		contenidosVistos.filter { contenido => contenido.esDeGenero(genero) }
		
	/* Punto 5.b */
	method esFanDe(actor) = contenidosVistos.all { contenido => contenido.actuo(actor) }
}

class Contenido {
	method genero()
	method actuo(actor)
	
	method esDeGenero(genero) = genero == self.genero()
}

class ContenidoUnitario inherits Contenido {
	/* Punto 2 */
	const property duracion
	
	method fueVistoCompleto(usuario) = usuario.vio(self) // double-dispatch
}

class Pelicula inherits ContenidoUnitario {
	const property genero
	const property actores = #{}
	
	override method actuo(actor) = actores.contains(actor)
}

class Capitulo inherits ContenidoUnitario { 
	var property temporada
	const property actoresInvitados = #{}
	
	override method genero() = temporada.genero()
	
	override method actuo(actor) = 
		actoresInvitados.contains(actor) or temporada.protagonizadoPor(actor)
}

class ContenidoCompuesto inherits Contenido {
	method componentes()
	
	/* Punto 2 */
	method duracion() = 
		self.componentes().sum { componente => componente.duracion() }
	
	method fueVistoCompleto(usuario) =
		self.componentes().all { componente => usuario.vioCompleto(componente) }

	override method actuo(actor) = 
		self.componentes().any { componente => componente.actuo(actor) }
}

class Temporada inherits ContenidoCompuesto {
	const capitulos = []
	const cantidadCapitulos
	var property serie

	override method componentes() = capitulos
	
	override method fueVistoCompleto(usuario) = 
		self.estaCompleta() and super(usuario)
		
 	method estaCompleta() = capitulos.size() == cantidadCapitulos 
 	
 	method ultimoCapitulo() = capitulos.last()
 	
	override method genero() = serie.genero()
	
	method protagonizadoPor(actor) = serie.protagonizadaPor(actor)
	
	/* Punto 7 */
	method crearCapitulo(duracion, numero, actoresInvitados) {
		self.validarNumeroCapitulo(numero)
		const capitulo = 
			new Capitulo(
				duracion = duracion, 
				temporada = self,
				actoresInvitados = actoresInvitados
			)
		capitulos.add(capitulo)
	}
	
	method validarNumeroCapitulo(numero) {
		if (not (numero == capitulos.size() + 1))
			throw new NumeroCapituloInvalidoException(
				message = "Sólo puede agregarse el siguiente capítulo a los existentes"
			)			
		if (numero > cantidadCapitulos)
			throw new NumeroCapituloInvalidoException(
				message = "La temporada ya está completa"
			)			
	}
}

class Serie inherits ContenidoCompuesto {
	const temporadas = []
	const property genero = ""
	const property actores = #{}
	
	override method componentes() = temporadas
	
	/* Punto 3 */
	method ultimoCapitulo() = temporadas.last().ultimoCapitulo()
	
	method protagonizadaPor(actor) = actores.contains(actor)
}

class Actor {
	/* Punto 5.a */
	method actuoEn(contenido) = contenido.actuo(self)
}

object repositorio {
	const property destacados = #{}
	
	/* Punto 6 */
	/* method recomiendaA(usuario) =
		destacados.union(usuario.vioIncompleto()) */
}

class NumeroCapituloInvalidoException inherits Exception {}