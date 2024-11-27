all:

ifeq ($(OS),Windows_NT)
RM		= del /f /q
RMR		= del /f /s /q
else
RM		= rm -f
RMR		= rm -f -r
endif

clean:
	$(RMR) *.cache
	$(RMR) *.hw
	$(RMR) *.runs
	$(RMR) *.sim
	$(RMR) *.ip_user_files
	$(RMR) .Xil
	$(RM) *~
