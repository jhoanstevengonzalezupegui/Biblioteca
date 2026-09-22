# ==============================================================================
# SISTEMA DE GESTIÓN DE BIBLIOTECA
# ==============================================================================
# CONCEPTOS APLICADOS:
# 1. LISTAS (`List`): La lista principal `libros` y la lista `categorias` de cada libro.
# 2. TUPLAS (`Tuple`): Para estados de retorno `{:ok, datos}` y `{:error, mensaje}`.
# 3. MAPAS (`Map`): La estructura de cada libro `%{id: ..., titulo: ..., ...}`.
# 4. MÓDULO `Enum` (CRUD Completo):
#    - Enum.find/2   -> READ (Buscar libro por ID)
#    - Enum.each/2   -> READ (Listar libros)
#    - Enum.filter/2 -> READ (Filtrar por libros disponibles)
#    - Enum.map/2    -> UPDATE (Actualizar estado de préstamo)
#    - Enum.reject/2 -> DELETE (Eliminar libro de la lista)
# ==============================================================================

defmodule Biblioteca do
  @moduledoc """
  Modulo principal de la biblioteca para la gestion del catalogo.
  """

  # ----------------------------------------------------------------------------
  # 1. CREATE: Agregar nuevo libro a la lista
  # ----------------------------------------------------------------------------
  def agregar_libro(libros, id, titulo, autor, categorias) do
    case Enum.find(libros, fn libro -> libro.id == id end) do
      nil ->
        nuevo_libro = %{
          id: id,
          titulo: titulo,
          autor: autor,
          categorias: categorias,
          prestado: false
        }

        {:ok, libros ++ [nuevo_libro]}

      _existente ->
        {:error, "Ya existe un libro registrado con el ID #{id}."}
    end
  end

  # ----------------------------------------------------------------------------
  # 2. READ: Listar, Buscar y Filtrar
  # ----------------------------------------------------------------------------
  def listar_libros(libros) do
    if Enum.empty?(libros) do
      Util.mostrar_mensaje("\nLa biblioteca no tiene libros registrados.")
    else
      Util.mostrar_mensaje("\n--- CATALOGO GENERAL DE LA BIBLIOTECA ---")

      Enum.each(libros, fn libro ->
        estado = if libro.prestado, do: "PRESTADO", else: "DISPONIBLE"
        texto_categorias = Enum.join(libro.categorias, ", ")

        Util.mostrar_mensaje(
          "ID: #{libro.id} | Titulo: \"#{libro.titulo}\" | Autor: #{libro.autor} | Categorias: [#{texto_categorias}] | Estado: #{estado}"
        )
      end)
    end
  end

  def buscar_libro(libros, id) do
    case Enum.find(libros, fn libro -> libro.id == id end) do
      nil -> {:error, "Libro no encontrado."}
      libro -> {:ok, libro}
    end
  end

  def listar_disponibles(libros) do
    disponibles = Enum.filter(libros, fn libro -> libro.prestado == false end)

    if Enum.empty?(disponibles) do
      Util.mostrar_mensaje("\nNo hay libros disponibles en este momento.")
    else
      Util.mostrar_mensaje("\n--- LIBROS DISPONIBLES PARA PRESTAMO ---")

      Enum.each(disponibles, fn libro ->
        Util.mostrar_mensaje("ID: #{libro.id} | Titulo: \"#{libro.titulo}\" | Autor: #{libro.autor}")
      end)
    end
  end

  # ----------------------------------------------------------------------------
  # 3. UPDATE: Modificar datos y cambiar estado de prestamo
  # ----------------------------------------------------------------------------
  def actualizar_libro(libros, id, nuevo_titulo, nuevo_autor, nuevas_categorias) do
    if Enum.find(libros, fn libro -> libro.id == id end) do
      nueva_lista =
        Enum.map(libros, fn libro ->
          if libro.id == id do
            %{libro | titulo: nuevo_titulo, autor: nuevo_autor, categorias: nuevas_categorias}
          else
            libro
          end
        end)

      {:ok, nueva_lista}
    else
      {:error, "No se encontro el libro con ID #{id}."}
    end
  end

  def cambiar_estado_prestamo(libros, id, nuevo_estado) do
    if Enum.find(libros, fn libro -> libro.id == id end) do
      nueva_lista =
        Enum.map(libros, fn libro ->
          if libro.id == id do
            %{libro | prestado: nuevo_estado}
          else
            libro
          end
        end)

      {:ok, nueva_lista}
    else
      {:error, "No se encontro el libro con ID #{id}."}
    end
  end

  # ----------------------------------------------------------------------------
  # 4. DELETE: Eliminar libro de la lista
  # ----------------------------------------------------------------------------
  def eliminar_libro(libros, id) do
    if Enum.find(libros, fn libro -> libro.id == id end) do
      nueva_lista = Enum.reject(libros, fn libro -> libro.id == id end)
      {:ok, nueva_lista}
    else
      {:error, "No se encontro el libro para eliminar."}
    end
  end

  # ----------------------------------------------------------------------------
  # INTERFAZ Y BUCLE RECURSIVO
  # ----------------------------------------------------------------------------
  def iniciar do
    libros_iniciales = [
      %{
        id: 1,
        titulo: "Cien Anos de Soledad",
        autor: "Gabriel Garcia Marquez",
        categorias: ["Realismo Magico", "Novela"],
        prestado: false
      },
      %{
        id: 2,
        titulo: "El Principito",
        autor: "Antoine de Saint-Exupery",
        categorias: ["Fabula", "Infantil"],
        prestado: true
      }
    ]

    loop(libros_iniciales)
  end

  defp loop(libros) do
    Util.mostrar_mensaje("""
    \n--- GESTION DE BIBLIOTECA ---
    1. Ver catalogo completo
    2. Buscar libro por ID
    3. Ver libros disponibles
    4. Registrar nuevo libro
    5. Actualizar informacion de un libro
    6. Cambiar estado de prestamo
    7. Eliminar libro
    8. Salir
    """)

    opcion = Util.ingresar("Seleccione una opcion: ", :texto)

    case opcion do
      "1" ->
        listar_libros(libros)
        loop(libros)

      "2" ->
        id = Util.ingresar("Ingrese el ID a buscar: ", :entero)

        case buscar_libro(libros, id) do
          {:ok, libro} ->
            estado = if libro.prestado, do: "PRESTADO", else: "DISPONIBLE"
            Util.mostrar_mensaje("\nEncontrado: \"#{libro.titulo}\" de #{libro.autor} [Estado: #{estado}]")

          {:error, mensaje} ->
            Util.mostrar_error("\nError: #{mensaje}")
        end

        loop(libros)

      "3" ->
        listar_disponibles(libros)
        loop(libros)

      "4" ->
        id = Util.ingresar("Ingrese ID del libro: ", :entero)
        titulo = Util.ingresar("Ingrese el titulo: ", :texto)
        autor = Util.ingresar("Ingrese el autor: ", :texto)

        texto_categorias = Util.ingresar("Ingrese las categorias (separadas por coma): ", :texto)
        categorias = String.split(texto_categorias, ",") |> Enum.map(&String.trim/1)

        case agregar_libro(libros, id, titulo, autor, categorias) do
          {:ok, nueva_lista} ->
            Util.mostrar_mensaje("Libro registrado con exito.")
            loop(nueva_lista)

          {:error, mensaje} ->
            Util.mostrar_error("Error: #{mensaje}")
            loop(libros)
        end

      "5" ->
        id = Util.ingresar("Ingrese el ID del libro a actualizar: ", :entero)

        case buscar_libro(libros, id) do
          {:ok, _libro} ->
            titulo = Util.ingresar("Ingrese el nuevo titulo: ", :texto)
            autor = Util.ingresar("Ingrese el nuevo autor: ", :texto)
            texto_categorias = Util.ingresar("Ingrese las nuevas categorias (separadas por coma): ", :texto)
            categorias = String.split(texto_categorias, ",") |> Enum.map(&String.trim/1)

            {:ok, nueva_lista} = actualizar_libro(libros, id, titulo, autor, categorias)
            Util.mostrar_mensaje("Libro actualizado con exito.")
            loop(nueva_lista)

          {:error, mensaje} ->
            Util.mostrar_error("Error: #{mensaje}")
            loop(libros)
        end

      "6" ->
        id = Util.ingresar("Ingrese el ID del libro a modificar: ", :entero)

        case buscar_libro(libros, id) do
          {:ok, libro} ->
            nuevo_estado = !libro.prestado
            {:ok, nueva_lista} = cambiar_estado_prestamo(libros, id, nuevo_estado)
            mensaje_estado = if nuevo_estado, do: "marcado como PRESTADO", else: "marcado como DISPONIBLE"
            Util.mostrar_mensaje("El libro \"#{libro.titulo}\" ahora esta #{mensaje_estado}.")
            loop(nueva_lista)

          {:error, mensaje} ->
            Util.mostrar_error("Error: #{mensaje}")
            loop(libros)
        end

      "7" ->
        id = Util.ingresar("Ingrese el ID del libro a eliminar: ", :entero)

        case eliminar_libro(libros, id) do
          {:ok, nueva_lista} ->
            Util.mostrar_mensaje("Libro eliminado correctamente.")
            loop(nueva_lista)

          {:error, mensaje} ->
            Util.mostrar_error("Error: #{mensaje}")
            loop(libros)
        end

      "8" ->
        Util.mostrar_mensaje("\nGracias por usar el sistema de biblioteca.")

      _ ->
        Util.mostrar_error("Opcion invalida, intente de nuevo.")
        loop(libros)
    end
  end
end

Biblioteca.iniciar()
