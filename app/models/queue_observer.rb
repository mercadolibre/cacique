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
# == Schema Information
# Schema version: 20101129203650
#
# Table name: queue_observers
#
#  id         :integer(4)      not null, primary key
#  values     :string(600)
#  created_at :datetime
#  updated_at :datetime
#

class QueueObserver < ActiveRecord::Base

    def get_values
        info=QueueObserver.run
        self.values=""      
        info.each_pair {|u,v| self.values << "#{u}=#{v};"}
    end

    def read_values
       arr=self.values.split ";"
       info=Hash.new
       arr.each  do |value| 
           aux=value.split("=")
           info[aux[0].to_sym]=aux[1].to_s
       end
       info      
    end

    def self.run
        begin 
          @conection=Starling.new("#{IP_QUEUE}:#{PORT_QUEUE}")
          info=@conection.sizeof(:all)
          info[:total_queued_task]=info.values.sum
        rescue
          info={:error => _("Conection Error")}
        end
        info
    end
end
