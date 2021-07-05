export PROJECT=7800openbios

main: 	${PROJECT}.a78

${PROJECT}.a78: ${PROJECT}.asm
	dasm ${PROJECT}.asm -f3 -v0 -I. -I../includes -o${PROJECT}.bin -l${PROJECT}.list.txt
	
clean:
	/bin/rm -f ${PROJECT}.bin a.out ${PROJECT}.bin ${PROJECT}.list.txt

