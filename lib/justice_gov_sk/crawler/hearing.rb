module JusticeGovSk
  class Crawler
    class Hearing < JusticeGovSk::Crawler
      protected
    
      def process(request)
        super do
          uri = JusticeGovSk::Request.uri(request)
          
          @hearing = hearing_by_uri_factory.find_or_create(uri)
          
          @hearing.uri = uri
  
          @hearing.case_number = @parser.case_number(@document)
          @hearing.file_number = @parser.file_number(@document)
          @hearing.date        = @parser.date(@document)
          @hearing.room        = @parser.room(@document)
          @hearing.note        = @parser.note(@document)
        
          proceeding
          court
          
          section
          subject
          form
          
          yield
        end
      end
      
      def proceeding
        proceeding = proceeding_by_file_number_factory.find_or_create(@hearing.file_number)
        
        proceeding.file_number = @hearing.file_number
          
        @hearing.proceeding = proceeding
          
        @persistor.persist(proceeding) if proceeding.id.nil?
      end
      
      def court
        name = @parser.court(@document)
        
        unless name.nil?
          court = court_by_name_factory.find(name)
          
          @hearing.court = court
        end
      end
      
      def judges
        names = @parser.judges(@document)
    
        unless names.empty?
          puts "Processing #{pluralize names.count, 'judge'}."
          
          names.each do |name|
            judge = judge_by_name_factory.find(name[:altogether])
            exact = nil
            
            unless judge.nil?
              exact = true
            # TODO refactor, see todos in decree crawler
            #else
            #  judge = judge_factory_by_last_and_middle_and_first(name[:names])
            #  exact = false unless judge.nil?
            end
            
            judging(judge, name, exact)
          end
        end
      end
      
      def section
        value = @parser.section(@document)
        
        unless value.nil?
          section = hearing_section_by_value_factory.find_or_create(value)
          
          section.value = value
          
          @persistor.persist(section) if section.id.nil?
          
          @hearing.section = section
        end
      end
      
      def subject
        value = @parser.subject(@document)
        
        unless value.nil?
          subject = hearing_subject_by_value_factory.find_or_create(value)
          
          subject.value = value
          
          @persistor.persist(subject) if subject.id.nil?
          
          @hearing.subject = subject
        end
      end
      
      def form
        value = @parser.form(@document)
        
        unless value.nil?
          form = hearing_form_by_value_factory.find_or_create(value)
          
          form.value = value
          
          @persistor.persist(form) if form.id.nil?
          
          @hearing.form = form          
        end
      end
      
      private
      
      def judging(judge, name, exact)
        judging = judging_by_judge_id_and_hearing_id_factory.find_or_create(judge.id, @hearing.id)
        
        judging.judge                  = judge
        judging.judge_matched_exactly  = exact
        judging.judge_name_unprocessed = name[:unprocessed]

        judging.hearing = @hearing
        
        @persistor.persist(judging) if judging.id.nil?
      end
    end
  end
end
