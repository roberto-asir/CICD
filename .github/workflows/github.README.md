# Github Actions README

## Índice
- :ballot_box_with_check:[Requisitos previos](#requisitos-previos)
- :spiral_notepad:[Archivo yaml](#archivo-yaml)
- :cop:[Autorización manual](#autorizacion-manual)
- :hamburger:[Fuera de carta](#fuera-de-carta)

## Requisitos previos

Es necesario añadir las credenciales de AWS en el repositorio.

Para ello se accede a Settings (del propio repositorio) >> Secrets >> Actions y se añaden la clave y el secreto de la credencial de AWS: `AWS_SECRET_ACCESS_KEY` y `AWS_ACCESS_KEY_ID`


![Captura desde 2022-11-05 19-29-45](https://user-images.githubusercontent.com/2046110/200135499-0dd609c6-7378-4141-a638-5b63ec4ba356.png)



## Archivo yaml

El archivo que ejecuta el workflow de Github action para el despliegue está en este enlace:

https://github.com/KeepCodingCloudDevops6/cicd-roberto/blob/main/.github/workflows/main.yml

## Autorizacion manual

Para poder realizar una aprovación manual del despliegue  es necesario que el repositorio sea **público**

Hay que realizar 2 acciones para generar el proceso de aprovación manual:

- Configuración dentro del proyecto de un entorno desde `settings > environment`. **Es necesario** marcar la opción `Required reviewers` y añadir algún usuario con acceso al repositorio para que se le puedan notificar aprovaciones pendientes. 
- En el propio archivo del job de Github Actions indicar que se va a usar el entorno con la siguiente linea dentro del job: ` environment: NOMBRE_DEL_ENTORNO`

![Captura desde 2022-11-05 19-36-34](https://user-images.githubusercontent.com/2046110/200135671-957bc2d6-19c9-49e4-a9d4-f3b89ccf30ce.png)

![Captura desde 2022-11-04 13-54-17](https://user-images.githubusercontent.com/2046110/200135710-5ae285d0-bb22-4a96-addc-8b6e499a7d46.png)

![Captura desde 2022-11-04 13-56-11](https://user-images.githubusercontent.com/2046110/200135714-5d2c1308-4fb4-4648-b548-7c118db057ee.png)



## Fuera de carta

Simplemente comentar que el propio pipeline borra el bucket en el último paso.

No hay un motivo técnico para ello es únicamente por comodidad para no tener que borrarlo a mano y por eso tan DevOps de automatizar las tareas.

