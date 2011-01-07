 #
 #  @Authors:    
 #      Brizuela Lucia                  lula.brizuela@gmail.com
 #      Guerra Brenda                   brenda.guerra.7@gmail.com
 #      Crosa Fernando                  fernandocrosa@hotmail.com
 #      Branciforte Horacio             horaciob@gmail.com
 #      Luna Juan                       juancluna@gmail.com
 #      
 #  @copyright (C) 2010 MercadoLibre S.R.L
 #
 #
 #  @license        GNU/GPL, see license.txt
 #  This program is free software: you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation, either version 3 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program.  If not, see http://www.gnu.org/licenses/.
 #
module SuiteExecutionsHelper

  def any_failed? average
    average[:failed] > 0? true: false
  end
  
  def average(suite_execution)
    status = suite_execution.executions.map(&:status)
    total = 0
    success = 0
    failed = 0
    status.each do |s|
      if s != 4
        if s == 2
          success += 1
        elsif s ==3
          failed += 1
        end
        total += 1
      end
    end
    if total == 0
	    ss = 0
	    ff = 0
    else
	    ss = success*100/total
	    ff = failed*100/total
    end
    {:success => (ss), :failed => (ff)}
  end
  
end
